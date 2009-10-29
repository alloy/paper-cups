require File.expand_path('../../test_helper', __FILE__)
require 'test/spec/rails/macros'

describe "Macros::Proxy" do
  it "should store an instance of the test case" do
    test_case = mock('TestCase')
    proxy = Test::Spec::Rails::Macros::Proxy.new(test_case)
    proxy.test_case.should == test_case
  end
end

describe "Macros::Should" do
  it "should store an instance of the test_case" do
    test_case = mock('TestCase')
    proxy = Test::Spec::Rails::Macros::Should.new(test_case)
    proxy.test_case.should == test_case
  end
end

class Case
  extend Test::Spec::Rails::Macros::ClassMethods
  include Test::Spec::Rails::Macros::InstanceMethods
  
  def events(name)
    "fixture: #{name.inspect}"
  end
end

describe "A test case with support for macros" do
  it "should return a Should instance" do
    Case.new.should.should.be.kind_of?(Test::Spec::Rails::Macros::Should)
  end
  
  it "should know what are valid fixtures" do
    Case.stubs(:fixture_table_names).returns(%w(events venues))
    Case.known_fixture?(:events).should == true
    Case.known_fixture?(:venues).should == true
    Case.known_fixture?(:unknown).should == false
  end
  
  it "should know there are no fixtures when there are no fixture_table_names in the test" do
    Case.stubs(:respond_to?).with(:fixture_table_names).returns(false)
    Case.known_fixture?(:events).should == false
    Case.known_fixture?(:venues).should == false
    Case.known_fixture?(:unknown).should == false
  end
  
  it "should wrap know fixture methods in a lambda so they don't have to be known yet" do    
    Case.stubs(:fixture_table_names).returns(%w(events venues))
    Case.events(:bitterzoet).should.be.kind_of?(Test::Spec::Rails::Macros::LazyValue)
    Case.events(:bitterzoet).value.should == "events(:bitterzoet)"
  end
end

describe "A test case instance with support for macros" do
  before do
    @case = Case.new
    Case.stubs(:fixture_table_names).returns(%w(events))
  end
  
  it "should immediate LazyValue values in the context of the current test" do
    @case.immediate_values(:name => Test::Spec::Rails::Macros::LazyValue.new('events(:bitterzoet)')).should == {
      :name => 'fixture: :bitterzoet'
    }
  end
  
  it "should immediate Proc values" do
    @case.immediate_values(:name => Proc.new { 42 }).should == { :name => 42 }
  end
  
  it "should not change actual values" do
    @case.immediate_values(:name => 42).should == { :name => 42 }
  end
  
  it "should immediate nested values" do
    @case.immediate_values(:venue => { :name => Proc.new { 'bitterzoet' } }).should == {:venue => {:name => 'bitterzoet'}}
  end
end