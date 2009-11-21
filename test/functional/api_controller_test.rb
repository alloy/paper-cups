require File.expand_path('../../test_helper', __FILE__)

class TestApiController < ApiController
  allow_access :authenticated
  
  def private_action
    render :nothing => true
  end
end

ActionController::Routing::Routes.draw do |map|
  map.test_api '/api/:api_token/private_action', :controller => 'test_api', :action => :private_action
end

describe "On the", TestApiController, "a visitor" do
  it "should be able to authenticate with a token" do
    get :private_action, :api_token => members(:api).api_token
    status.should.be :success
    assigns(:authenticated).should == members(:api)
  end
  
  it "should not be able to authenticate with a token if the api_token field is blank" do
    get :private_action, :api_token => ''
    should.redirect_to new_session_url
    should.not.be.authenticated
    
    lambda {
      get :private_action, :api_token => nil
    }.should.raise ActionController::RoutingError
    should.not.be.authenticated
  end
  
  should.require_login.get :private_action, :api_token => 'fbeh33f'
end