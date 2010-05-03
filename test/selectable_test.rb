require File.join(File.dirname(__FILE__), "test_helper")

class SelectableTest < ActiveSupport::TestCase
  setup do
    Rails.test_environment = false
    State.cache_store.clear
    load_fixtures
  end

  teardown do
    cleanup_db
  end

  test "select_options class method is defined" do
    assert State.respond_to? :select_options
  end

  test "select_options returns an option per db record" do
    assert_equal State.count, State.select_options.length
    assert_equal ['Arizona','California','Colorado','New York','Texas'], State.select_options.map(&:first)
  end

  test "grouped select options" do
    grouped_states = State.select_options(:group => lambda{|state| state.name[0,1] })
    assert_equal %w[ A C N T ], grouped_states.map(&:first)
    grouped_states.each do |group, states|
      if group == 'C'
        assert_equal 2, states.length
      else
        assert_equal 1, states.length
      end
    end
  end

  test "cache key depends on scope" do
    assert_equal State.count, State.select_options.length
    assert_equal ['Arizona','California','Colorado','New York','Texas'], State.select_options.map(&:first)

    assert_equal 2, State.starting_with_C.select_options.length
    assert_equal ['California','Colorado'], State.starting_with_C.select_options.map(&:first)
  end

  test "default scope find options are respected" do
    assert_equal ['Renminbi', 'Euro', 'Pound Sterling', 'US Dollar'], Currency.select_options.map(&:first)
  end

  test "overriding the key and value generation" do
    assert_equal %w( CNY EUR GBP USD ), Currency.select_options(:code).map(&:first)
    assert_equal [['Renminbi','CNY'],['Euro','EUR'],['Pound Sterling','GBP'],['US Dollar', 'USD']], Currency.select_options(:name, :code)
  end

  test "caching" do
    @states = State.all
    State.expects(:find).once.returns(@states)

    5.times do
      assert_equal State.count, State.select_options.length
    end
  end

  test "forcing cache miss in test environment" do
    Rails.test_environment = true

    @states = State.all
    State.expects(:find).times(5).returns(@states)

    5.times do
      assert_equal State.count, State.select_options.length
    end
  end

  test "create or update clears the cache" do
    assert_equal State.count, State.select_options.length

    assert_difference 'State.count' do
      State.create!(:name => "New Jersey", :abbreviation => "NJ")
    end

    assert_equal 'Arizona', State.select_options.first.first
    assert_equal State.count, State.select_options.length

    @state = State.find_by_abbreviation('AZ')
    @state.name = 'AZ -- Keep Out'
    @state.save

    assert_equal 'AZ -- Keep Out', State.select_options.first.first
  end

  test "non-column ordering is not defaulted" do
    assert_nothing_raised { CustomDisplay.select_options }
  end

  test "specifying defaults at the model level" do
    assert_equal State.select_options(:value => :abbreviation), CustomDisplayDeux.select_options
  end

  test "overriding model-level defaults" do
    assert_equal State.select_options, CustomDisplayDeux.select_options(:value => :name)
  end

  test "empty table generates empty select options" do
    State.all.map(&:destroy)
    assert_nothing_raised {
      assert_equal [], State.select_options
    }
  end

end
