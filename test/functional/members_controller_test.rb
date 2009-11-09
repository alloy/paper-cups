require File.expand_path('../../test_helper', __FILE__)

describe "On the", MembersController, "an admin" do
  before do
    login members(:alloy)
  end
  
  it "should see a form to invite a new member to a room" do
    get :new, :room_id => rooms(:macruby)
    assigns(:room).should == rooms(:macruby)
    status.should.be :ok
    template.should.be 'members/new'
    assert_select "form[action=#{room_members_path(rooms(:macruby))}]"
  end
  
  it "should create a new member and send an invitation" do
    token = Token.generate
    Token.stubs(:generate).returns(token)
    
    assert_emails 1 do
      lambda {
        lambda {
          post :create, :room_id => rooms(:macruby), :member => { :email => 'dionne@example.com' }
        }.should.differ('Membership.count', +1)
      }.should.differ('Member.count', +1)
    end
    
    assigns(:member).email.should == 'dionne@example.com'
    assigns(:member).invitation_token.should == token
    assigns(:member).memberships.map(&:room).should == [rooms(:macruby)]
    ActionMailer::Base.deliveries.last.to.should == ['dionne@example.com']
    
    should.redirect_to root_url
  end
end

module ValidMember
  def valid_params
    { :full_name => 'Jurgen von Apfel', :email => 'jurgen@example.com', :password => 'so secret', :verify_password => 'so secret' }
  end
end

describe "On the", MembersController, "a visitor" do
  include ValidMember
  
  it "should not see a form for a new member" do
    get :new
    should.redirect_to new_session_url
  end
  
  it "should not be able to create a new member" do
    lambda {
      post :create, :member => valid_params
    }.should.not.differ('Member.count')
    should.redirect_to new_session_url
  end
  
  it "should see an edit form with an invitation token instead of id" do
    member = Member.create!(:email => 'new@example.com')
    get :edit, :id => member.invitation_token

    assert_select 'form'
    assigns(:member).should == member
    status.should.be :success
    template.should.be 'members/edit'
  end
  
  it "should be able to update his profile and be logged in" do
    member = Member.create!(:email => 'new@example.com')
    put :update, :id => member.invitation_token, :member => valid_params
    
    member.reload.full_name.should == valid_params[:full_name]
    member.email.should == valid_params[:email]
    member.invitation_token.should.be nil
    
    should.be.authenticated
    should.redirect_to rooms_url
  end
  
  it "should show validation errors after a failed update" do
    member = Member.create!(:email => 'new@example.com')
    put :update, :id => member.invitation_token, :member => valid_params.merge(:email => '')
    
    status.should.be :ok
    template.should.be 'members/edit'
    assert_select 'div.errorExplanation'
    assert_select 'form'
    should.not.be.authenticated
  end
  
  should.require_login.get :show, :id => members(:alloy)
  should.require_login.get :edit, :id => members(:alloy)
  should.require_login.put :update, :id => members(:alloy)
  should.require_login.delete :destroy, :id => members(:alloy)
end

describe "On the", MembersController, "a member" do
  include ValidMember
  
  before do
    login members(:lrz)
  end
  
  it "should not see a form for a new member" do
    get :new
    status.should.be :forbidden
  end
  
  it "should not be able to create a new member" do
    lambda {
      post :create, :member => valid_params
    }.should.not.differ('Member.count')
    status.should.be :forbidden
  end
  
  it "should see an edit form" do
    get :edit, :id => @authenticated.to_param
    
    assert_select 'form'
    assigns(:member).should == @authenticated
    status.should.be :success
    template.should.be 'members/edit'
  end
  
  it "should be able to update his profile" do
    put :update, :id => @authenticated.to_param, :member => { :email => 'sir.eloy@example.com' }
    
    @authenticated.reload.email.should == 'sir.eloy@example.com'
    should.redirect_to member_url(@authenticated)
  end
  
  should.disallow.get :edit, :id => members(:alloy)
  should.disallow.put :update, :id => members(:alloy)
  should.disallow.delete :destroy, :id => members(:alloy)
end