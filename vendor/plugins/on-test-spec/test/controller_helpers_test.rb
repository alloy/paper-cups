require File.expand_path('../test_helper', __FILE__)
require 'test/spec/rails/request_helpers'
require 'test/spec/rails/response_helpers'
require 'test/spec/rails/controller_helpers'

class ActionControllerClass < ActionController::Base; end

describe ActionControllerClass, "response helpers for a controller test" do
  it "should map #controller to the controller instance" do
    controller.should == @controller
  end
  
  it "should map #status to the response status" do
    expects(:assert_response).with(:success, 'the message')
    status.should.be :success, 'the message'
  end
  
  it "should map #template to the response template" do
    expects(:assert_template).with('show', 'the message')
    template.should.be 'show', 'the message'
  end
  
  it "should map #layout to the response layout" do
    @response.stubs(:layout).returns('layouts/application')
    expects(:assert_equal).with('application', 'application', 'the message')
    layout.should.be 'application', 'the message'
  end
end

describe ActionControllerClass, "request helpers for a controller test" do
  it "should make @request available as an accessor" do
    request.should.be @request
  end
end