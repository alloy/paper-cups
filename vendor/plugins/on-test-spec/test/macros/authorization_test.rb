require File.expand_path('../../test_helper', __FILE__)
require 'test/spec/rails/macros'

describe "TestGenerator, concerning generation" do
  before do
    @test = mock('Test')
    @generator = Test::Spec::Rails::Macros::Authorization::TestGenerator.new(@test, :access_denied?, true, 'Expected access to be denied')
  end
  
  it "should generate a test description for a GET" do
    @test.expects(:it).with("should disallow GET on `index'")
    @generator.get(:index)
  end
  
  it "should generate a test description for a POST with params" do
    @test.expects(:it).with("should disallow POST on `create\' {:venue=>{:name=>\"Bitterzoet\"}}")
    @generator.post(:create, :venue => { :name => "Bitterzoet" })
  end
  
  it "should raise a NoMethodError when you disallow an unknown HTTP verb" do
    lambda {
      @generator.unknown :index
    }.should.raise(NoMethodError)
  end
end

class Immediate
  def self.it(description, &block)
    block.call
  end
end

describe "TestGenerator, concerning test contents" do
  before do
    @generator = Test::Spec::Rails::Macros::Authorization::TestGenerator.new(Immediate, :access_denied?, true, 'Expected access to be denied')
    @generator.stubs(:send).with(:access_denied?).returns(true)
  end
  
  it "should send the verb and options to the controller" do
    params = {:venue => {:name => "Bitterzoet"}}
    @generator.stubs(:immediate_values).with(params).returns(params)
    @generator.expects(:send).with(:post, :create, params)
    
    @generator.post(:create, params)
  end
  
  it "should immediate values in params" do
    params = {:name => 'bitterzoet'}
    
    @generator.expects(:immediate_values).with(params).returns(params)
    @generator.stubs(:send).returns(true)
    
    @generator.post(:create, params)
  end
  
  it "should test the return value of the validation method against the expected method" do
    @generator.expected = false
    params = {:name => 'bitterzoet'}
    
    @generator.expects(:immediate_values).with(params).returns(params)
    @generator.stubs(:send).returns(false)
    
    @generator.post(:create, params)
  end
end

describe "Macros::Authorization" do
  before do
    @test_case = mock('TestCase')
    @proxy = Test::Spec::Rails::Macros::Should.new(@test_case)
  end
  
  it "should return a test generator when a new disallow rule is invoked" do
    generator = @proxy.disallow
    
    generator.should.is_a(Test::Spec::Rails::Macros::Authorization::TestGenerator)
    generator.test_case.should == @test_case
    generator.validation_method.should == :access_denied?
    generator.message.should == 'Expected access to be denied'
    generator.expected.should == true
  end
  
  it "should return a test generator when a new allow rule is invoked" do
    generator = @proxy.allow
    
    generator.should.is_a(Test::Spec::Rails::Macros::Authorization::TestGenerator)
    generator.test_case.should == @test_case
    generator.validation_method.should == :access_denied?
    generator.message.should == 'Expected access to be allowed'
    generator.expected.should == false
  end
  
  it "should return a test generator when a new login_required rule is invoked" do
    generator = @proxy.require_login
    
    generator.should.is_a(Test::Spec::Rails::Macros::Authorization::TestGenerator)
    generator.test_case.should == @test_case
    generator.validation_method.should == :login_required?
    generator.message.should == 'Expected login to be required'
    generator.expected.should == true
  end
end