require File.dirname(__FILE__) + '/spec_helper.rb'

describe "an ActiveRecord model with finder defined" do

  before(:each) do
    Rails.test_environment = false
    State.cache_store.clear
    load_fixtures
  end

  after(:each) do
    cleanup_db
  end


  it "should respond to []" do
    State.should.respond_to? :[]
  end

  it "should enforce uniqueness of lookup token" do
    State[:CO].name.should == "Colorado"
    @state = State.new(:abbreviation => "CO")
    @state.should_not be_valid
  end

  it "should support hash-like lookup" do
    @colorado = State.find_by_name 'California'
    State[:CA].should == @colorado
  end

  it "should cache results in memory" do
    @state = State.create!(:abbreviation => "FL", :name => "Florida")
    State.expects(:find).once.returns(@state)

    5.times do
      State[:FL].name.should == "Florida"
    end
  end

  it "should force cache miss in Rails test environment" do
    Rails.test_environment = true

    @state = State.create!(:abbreviation => "FL", :name => "Florida")
    State.expects(:find).times(5).returns(@state)

    5.times do
      State[:FL].name.should == "Florida"
    end
  end
end
