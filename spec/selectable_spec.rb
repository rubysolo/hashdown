require File.dirname(__FILE__) + '/spec_helper.rb'

describe "an ActiveRecord model with selectable defined" do

  before(:each) do
    Rails.test_environment = false
    State.cache_store.clear
    load_fixtures
  end

  after(:each) do
    cleanup_db
  end


  it "should respond to select_options" do
    State.should.respond_to? :select_options
  end

  it "should return options for each record" do
    State.select_options.length.should == State.count
    State.select_options.map(&:first).should == ['Arizona','California','Colorado','New York','Texas']
  end

  it "should respect default scope find options" do
    Currency.select_options.map(&:first).should == ['Renminbi', 'Euro', 'Pound Sterling', 'US Dollar']
  end

  it "should allow overriding the key and value generation" do
    Currency.select_options(:code).map(&:first).should == %w( CNY EUR GBP USD )
    Currency.select_options(:name, :code).should == [['Renminbi','CNY'],['Euro','EUR'],['Pound Sterling','GBP'],['US Dollar', 'USD']]
  end

  it "should store results in cache" do
    @states = State.all
    State.expects(:find).once.returns(@states)

    5.times do
      State.select_options.length.should == State.count
    end
  end

  it "should force cache miss in Rails test environment" do
    Rails.test_environment = true

    @states = State.all
    State.expects(:find).times(5).returns(@states)

    5.times do
      State.select_options.length.should == State.count
    end
  end

  it "should not default non-column ordering" do
    lambda{ CustomDisplay.select_options }.should_not raise_error
  end

  it "should accept defaults at the model level" do
    CustomDisplayDeux.select_options.should == State.select_options(:value => :abbreviation)
  end

  it "should allow overriding model-level defaults" do
    CustomDisplayDeux.select_options(:value => :name).should == State.select_options
  end

end
