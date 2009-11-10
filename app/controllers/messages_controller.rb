class MessagesController < ApplicationController
  allow_access :authenticated
  
  find_parent_resource
  
  def index
    if params[:q]
      @messages = @room.search(params[:q])
    else
      day = params[:day].match(/^(\d{4})-(\d{2})-(\d{2})$/)
      @messages = @room.messages.find_created_on_date(day[1], day[2], day[3])
    end
  end
  
  def create
    @message = @room.messages.create(params[:message].merge(:author => @authenticated))
    redirect_to room_url(@room)
  end
end
