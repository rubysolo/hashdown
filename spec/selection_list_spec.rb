require File.dirname(__FILE__) + '/spec_helper.rb'

describe "an ActiveRecord model with selection_list defined" do
  after(:each) do
    cleanup_db
  end

  before(:each) do
    State.cache_store.clear
    load_fixtures
  end


  it "should respond to selectable" do
    State.should.respond_to? :selectable
  end

  it "should return options for each record" do
    State.select_options.length.should == State.count
    State.select_options.map(&:first).should == ['Arizona','California','Colorado','New York','Texas']
  end

  it "should respect default scope find options" do
    Currency.select_options.map(&:first).should == ['Renminbi', 'Euro', 'Pound Sterling', 'US Dollar']
  end

end
