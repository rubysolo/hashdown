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

  test "non-column ordering is not defaulted" do
    assert_nothing_raised { CustomDisplay.select_options }
  end

  test "specifying defaults at the model level" do
    assert_equal State.select_options(:value => :abbreviation), CustomDisplayDeux.select_options
  end

  test "overriding model-level defaults" do
    assert_equal State.select_options, CustomDisplayDeux.select_options(:value => :name)
  end

end
