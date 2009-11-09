class MembersController < ApplicationController
  allow_access :admin
  allow_access(:authenticated, :only => [:show, :edit, :update]) { @authenticated.to_param == params[:id] }
  allow_access(:all, :only => [:edit, :update]) { find_invitee }
  
  before_filter :find_member, :only => [:show, :edit, :update]
  
  find_parent_resource :only => [:new, :create]
  
  def new
    @member = Member.new
  end
  
  def create
    @member = Member.new(params[:member])
    @member.memberships.build(:room => @room)
    
    if @member.save
      @member.invite!
      redirect_to root_url
    else
      render :new
    end
  end
  
  def update
    if @member.update_attributes(params[:member])
      login @member
      redirect_to member_url(@member)
    else
      render :edit
    end
  end
  
  private
  
  def find_invitee
    if params[:id] =~ /[a-z]/
      @member = Member.find_by_invitation_token(params[:id])
    end
  end
  
  def find_member
    @member ||= Member.find(params[:id])
  end
end