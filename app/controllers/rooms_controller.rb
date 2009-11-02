class RoomsController < ApplicationController
  allow_access :authenticated
  
  def show
    @room = Room.find(params[:id])
  end
end
