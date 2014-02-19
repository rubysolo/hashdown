require 'spec_helper'

describe Hashdown::SelectOptions do
  let(:state_names) { %w(Arizona California Colorado New\ York Texas) }

  it 'adds #select_options to ActiveRecord classes declared selectable' do
    State.should respond_to(:select_options)
  end

  it 'returns one entry per database record' do
    State.select_options.length.should eq State.count
  end

  it 'sorts by label if no order is specified' do
    State.select_options.map(&:first).should eq state_names
  end

  it 'allows use of methods for labels' do
    State.select_options(:label).map(&:first).should eq(
      ['AZ (Arizona)', 'CA (California)', 'CO (Colorado)', 'NY (New York)', 'TX (Texas)']
    )
  end

  it 'respects order if specified' do
    Currency.select_options.map(&:first).should eq ['Renminbi', 'Euro', 'Pound Sterling', 'US Dollar']
  end

  it 'returns a list of records formatted for the #select form helper' do
    option = State.select_options.first
    option.first.should eq 'Arizona'
    option.last.should eq State[:AZ].id
  end

  it 'generates grouped options' do
    grouped_states = State.select_options(group: lambda { |state| state.name[0] })
    grouped_states.map(&:first).should eq %w( A C N T )
    grouped_states.detect{|group, states| group == 'C' }.last.length.should eq 2
  end

  it 'supports alternate option labels' do
    Currency.select_options(:code).map(&:first).should eq %w( CNY EUR GBP USD )
  end

  it 'supports alternate option values' do
    Currency.select_options(:name, :code).map(&:last).should eq %w( CNY EUR GBP USD )
  end

  describe 'cache layer' do
    let(:states) { State.all }
    let(:mock_scope) { double(arel: double(orders: %w( name )), to_sql: "SELECT * FROM states", where_values_hash: {}) }

    it 'should cache found records' do
      mock_scope.should_receive(:to_a).once.and_return(states)
      State.stub(:where).and_return(mock_scope)

      2.times { State.select_options.length.should eq states.length }
    end

    describe 'in test environment' do
      before { Object.const_set('Rails', double(env: double(test?: true), cache: ActiveSupport::Cache::MemoryStore.new)) }
      after  { Object.send(:remove_const, 'Rails') }

      it 'forces cache miss' do
        mock_scope.should_receive(:to_a).twice.and_return(states)
        State.stub(:where).and_return(mock_scope)

        2.times { State.select_options.length.should eq states.length }
      end
    end

    it 'respects scopes' do
      State.select_options.map(&:first).should eq state_names
      State.starting_with_c.select_options.map(&:first).should eq %w( California Colorado )
    end

    it 'respects associations' do
      City.starting_with_d.select_options.map(&:first).should eq %w( Dallas Denver )
      State[:TX].cities.starting_with_d.select_options.map(&:first).should eq %w( Dallas )
      State[:CO].cities.starting_with_d.select_options.map(&:first).should eq %w( Denver )
    end

    it 'clears the cache on save' do
      mock_scope.should_receive(:to_a).twice.and_return(states)
      State.stub(:where).and_return(mock_scope)

      State.select_options
      states.first.save
      State.select_options
    end

    it 'clears the cache on destroy' do
      mock_scope.should_receive(:to_a).twice.and_return(states)
      State.stub(:where).and_return(mock_scope)

      State.select_options
      states.first.destroy
      State.select_options
    end
  end
end
