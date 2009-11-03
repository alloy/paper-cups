class RoomsController < ApplicationController
  allow_access :authenticated
  
  def show
    @room = Room.find(params[:id])
    @authenticated.online_in(@room)
    respond_to do |format|
      format.html
      format.json
    end
  end
end
