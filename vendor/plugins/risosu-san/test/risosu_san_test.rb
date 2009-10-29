require File.expand_path('../test_helper', __FILE__)

class TestController < ActionController::Base
  public :nested?, :parent_resource_params, :find_parent_resource
  
  attr_reader :params
  def params=(params)
    @params = params.with_indifferent_access
  end
end

class CamelCaseTest
end

describe "RisosuSan, at the class level" do
  it "should define a before_filter which finds the parent resource" do
    TestController.expects(:before_filter).with(:find_parent_resource, {})
    TestController.find_parent_resource
  end
  
  it "should forward options to the before_filter" do
    TestController.expects(:before_filter).with(:find_parent_resource, :only => :index)
    TestController.find_parent_resource :only => :index
  end
end

describe "RisosuSan" do
  attr_accessor :controller
  
  before do
    RisosuSanTest::Initializer.setup_database
    
    @controller = TestController.new
    @member = Member.create(:name => 'Eloy')
  end
  
  after do
    RisosuSanTest::Initializer.teardown_database
  end
  
  it "should know if it's not a nested request" do
    controller.params = {}
    controller.should.not.be.nested
  end
  
  it "should know if this is a nested request" do
    controller.params = { :member_id => 12 }
    controller.should.be.nested
  end
  
  it "should know the parent resource params" do
    controller.params = { :member_id => 12, :id => 34 }
    controller.parent_resource_params.should == { :name => 'member', :class => Member, :param => 'member_id', :class_name => 'Member', :id => 12 }
  end
  
  it "should know the parent resource params for camelcased classes" do
    controller.params = { :camel_case_test_id => 12, :id => 34 }
    controller.parent_resource_params.should == { :name => 'camel_case_test', :class => CamelCaseTest, :param => 'camel_case_test_id', :class_name => 'CamelCaseTest', :id => 12 }
  end
  
  it "should have cached the parent_resource_params" do
    controller.params = { :member_id => 12, :id => 34 }
    params = controller.parent_resource_params
    controller.parent_resource_params.should.be params
  end
  
  it "should find the nested resource" do
    controller.params = { :member_id => @member.to_param }
    controller.find_parent_resource
    assigns(:parent_resource).should == @member
  end
  
  it "should also set an instance variable named after the parent resource" do
    controller.params = { :member_id => @member.to_param }
    controller.find_parent_resource.should == @member
    assigns(:member).should == @member
  end
  
  it "should return nil if the resource isn't nested" do
    controller.params = {}
    controller.find_parent_resource.should.be nil
    assigns(:parent_resource).should.be nil
  end
  
  private
  
  def assigns(name)
    controller.instance_variable_get("@#{name}")
  end
end