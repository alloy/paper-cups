class RoomsController < ApplicationController
  allow_access :authenticated, :only => :index
  allow_access :authenticated do
    (@membership = @authenticated.memberships.find_by_room_id(params[:id])) && @room = @membership.room
  end
  
  before_filter :adjust_format_for_ipad
  before_filter :adjust_format_for_iphone
  
  def index
    redirect_to room_url(@authenticated.memberships.first.room)
  end
  
  def update
    @room.set_topic(@authenticated, params[:room][:topic])
    respond_to do |format|
      format.js { render :text => @room.topic }
    end
  end
  
  def show
    @authenticated.online_in(@room)
    respond_to do |format|
      format.ipad { load_recent_messages }
      format.iphone { load_recent_messages }
      format.html { load_recent_messages }
      format.json { render :layout => false }
    end
  end
  
  private
  
  def load_recent_messages
    @messages = @room.messages.recent(@authenticated)
  end
end
