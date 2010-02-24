require File.join(File.dirname(__FILE__), "test_helper")

class FinderTest < ActiveSupport::TestCase
  setup do
    Rails.test_environment = false
    State.cache_store.clear
    load_fixtures
  end

  teardown do
    cleanup_db
  end

  test "finder-enabled model should respond to []" do
    assert State.respond_to?(:[])
  end

  test "enforcing uniqueness of lookup token" do
    assert_equal "Colorado", State[:CO].name
    @state = State.new(:abbreviation => "CO")
    assert ! @state.valid?
  end

  test "hash-like lookup" do
    @california = State.find_by_name 'California'
    assert_equal @california, State[:CA]
  end

  test "set default to prevent error" do
    assert_raises(RuntimeError) { State[:Boom] }
    assert_nothing_raised { NoErrorState[:FindDefault] }
    assert_nothing_raised {
      assert_equal "Not Found", StateWithDefault[:FindDefault]
    }
  end

  test "caching" do
    @state = State.create!(:abbreviation => "FL", :name => "Florida")
    State.expects(:find).once.returns(@state)

    5.times do
      @lookup = State[:FL]
      assert_equal "Florida", @lookup.name
    end
  end

  test "forcing cache miss in test environment" do
    Rails.test_environment = true

    @state = State.create!(:abbreviation => "FL", :name => "Florida")
    State.expects(:find).times(5).returns(@state)

    5.times do
      @lookup = State[:FL]
      assert_equal "Florida", @lookup.name
    end
  end
end
