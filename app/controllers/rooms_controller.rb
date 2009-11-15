class RoomsController < ApplicationController
  allow_access :authenticated
  
  def index
    redirect_to room_url(@authenticated.memberships.first.room)
  end
  
  def show
    @membership = @authenticated.memberships.find_by_room_id(params[:id])
    @room = @membership.room
    @authenticated.online_in(@room)
    respond_to do |format|
      format.html { @messages = @room.messages.recent }
      format.json
    end
  end
end
