class Api::MessagesController < ApiController
  allow_access(:authenticated) do
    if membership = @authenticated.memberships.find_by_room_id(params[:room_id])
      @room = membership.room
    end
  end
  
  def create
    @message = @room.messages.create(params[:message].merge(:author => @authenticated))
    head :created
  end
end
