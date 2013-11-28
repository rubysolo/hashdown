require 'spec_helper'

describe Hashdown::Finder do
  describe 'bracket lookup' do
    it 'is added to enabled models' do
      State.should respond_to(:[])
    end

    it 'finds a record by a string key value' do
      State['CA'].name.should eq 'California'
    end

    it 'finds a record by a symbol key value' do
      State[:CO].name.should eq 'Colorado'
    end

    it 'adds uniqueness validation to key attribute' do
      State.where(abbreviation: 'CO').count.should eq 1
      State.new(abbreviation: 'CO').should_not be_valid
    end
  end

  describe 'missing/invalid key' do
    it 'raises record not found exception' do
      lambda { State[:HI] }.should raise_error(ActiveRecord::RecordNotFound)
    end

    it 'allows setting a default to avoid exception' do
      lambda { StateDefaultNil[:HI].should be_nil }.should_not raise_error
    end
  end

  describe 'cache layer' do
    let(:florida) { State.new(abbreviation: 'FL', name: 'Florida') }

    it 'caches found records' do
      scope = double(first: florida)
      State.should_receive(:where).once.and_return(scope)

      2.times { State[:FL].name.should eq 'Florida' }
    end

    describe 'in test environment' do
      before { Object.const_set('Rails', double(env: double(test?: true), cache: ActiveSupport::Cache::MemoryStore.new)) }
      after  { Object.send(:remove_const, 'Rails') }

      it 'forces cache miss' do
        scope = double(first: florida)
        State.should_receive(:where).twice.and_return(scope)

        2.times { State[:FL].name.should eq 'Florida' }
      end
    end

    it 'clears the cache on save' do
      scope = double(first: florida)
      State.should_receive(:where).twice.and_return(scope)

      State[:FL].save
      State[:FL]
    end

    it 'clears the cache on destroy' do
      scope = double(first: florida)
      State.should_receive(:where).twice.and_return(scope)

      State[:FL].destroy
      State[:FL]
    end
  end
end
