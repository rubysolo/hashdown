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

  test "save or delete clears cache" do
    @state = State.create!(:abbreviation => "FL", :name => "Florida")

    3.times do
      lookup = State[:FL]
      assert_equal 'Florida', lookup.name
      State.connection.execute("UPDATE states SET name = 'Flooridia' WHERE abbreviation = 'FL'")
    end

    # update
    @modify = State.find(@state.id)
    @modify.name = 'Flooridia'
    @modify.save

    3.times do
      lookup = State[:FL]
      assert_equal 'Flooridia', lookup.name
      State.connection.execute("UPDATE states SET name = 'Florida' WHERE abbreviation = 'FL'")
    end

    # delete
    @state = NoErrorState[:FL]
    assert_equal "Florida", @state.name

    @delete = NoErrorState.find(@state.id)
    @delete.destroy

    @state = NoErrorState[:FL]
    assert @state.nil?
  end
end
