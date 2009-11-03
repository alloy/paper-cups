class MessagesController < ApplicationController
  allow_access :authenticated
  
  find_parent_resource
  
  def create
    @message = @room.messages.create(params[:message].merge(:author => @authenticated))
    redirect_to room_url(@room)
  end
end
