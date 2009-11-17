class RoomsController < ApplicationController
  allow_access :authenticated, :only => :index
  allow_access :authenticated do
    (@membership = @authenticated.memberships.find_by_room_id(params[:id])) && @room = @membership.room
  end
  
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
      format.html { @messages = @room.messages.recent }
      format.json
    end
  end
end
