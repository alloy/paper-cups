require File.expand_path('../test_helper', __FILE__)

class TestController < ApplicationController
  def does_not_need_authentication
    render :nothing => true
  end
  
  def needs_authentication
    authentication_needed! :extra_option => "I was merged!"
  end
  
  def needs_more_authentication
    still_authentication_needed!
    render :nothing => true
  end
  
  def authenticate
    finish_authentication_needed! or redirect_to(some_other_url)
  end
  
  private
  
  def when_authentication_needed
    redirect_to new_session_url
  end
  
  def new_session_url
    "http://test/sessions/new"
  end
  
  def some_other_url
    "http://test/manage/articles/new"
  end
end

class AuthenticationNeededTest < ActionController::TestCase
  tests TestController
  
  test "should set a redirect_to value, which is the requested url, if authentication is needed" do
    get :needs_authentication
    assert_equal url_for(:needs_authentication), flash[:after_authentication][:redirect_to]
  end
  
  test "should merge extra options into the after_authentication hash" do
    get :needs_authentication
    assert_equal "I was merged!", flash[:after_authentication][:extra_option]
  end
  
  test "should invoke the when_authentication_needed instance method after #authentication_needed! is done" do
    get :needs_authentication
    assert_redirected_to new_session_url
  end
  
  test "should raise a AuthenticationNeededSan::ProtocolNotImplementedError if the class does not implement the when_authentication_needed instance method" do
    class << @controller
      undef :when_authentication_needed
    end
    
    assert_raises(AuthenticationNeededSan::ProtocolNotImplementedError) { get :needs_authentication }
  end
  
  test "should return `false' if authentication is not needed" do
    get :does_not_need_authentication
    assert !@controller.send(:authentication_needed?)
  end
  
  test "should return `true' if authentication is needed" do
    get :needs_authentication
    assert @controller.send(:authentication_needed?)
  end
  
  test "should allow the authentication_needed data to survive an extra request if authentication is still needed" do
    flash = stubbed_flash
    flash.expects(:keep).with(:after_authentication)
    get :needs_more_authentication, {}, {}, flash
  end
  
  test "should redirect back to original user’s requested URL after authentication" do
    get :authenticate, {}, {}, { :after_authentication => { :redirect_to => new_session_url } }
    assert_redirected_to new_session_url
  end
  
  test "should discard the :after_authentication data when #finish_authentication_needed! is called" do
    flash = stubbed_flash
    flash.expects(:discard).with(:after_authentication)
    get :authenticate, {}, {}, flash
  end
  
  test "should return `false' when #finish_authentication_needed! is called but no :after_authentication data exists so the user can do something else" do
    get :authenticate
    assert_redirected_to some_other_url
  end
  
  private
  
  def url_for(action)
    @controller.url_for(:action => action)
  end
  
  def new_session_url
    @controller.send :new_session_url
  end
  
  def some_other_url
    @controller.send :some_other_url
  end
  
  def stubbed_flash
    flash = { :after_authentication => { :redirect_to => new_session_url } }
    @controller.stubs(:flash).returns(flash)
    flash
  end
end
