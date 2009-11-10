class RoomsController < ApplicationController
  allow_access :authenticated
  
  def index
    redirect_to room_url(@authenticated.memberships.first.room)
  end
  
  def show
    @room = Room.find(params[:id])
    @authenticated.online_in(@room)
    respond_to do |format|
      format.html { @messages = @room.messages.recent }
      format.json
    end
  end
end
