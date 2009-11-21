class Api::MessagesController < ApiController
  allow_access(:authenticated) do
    if membership = @authenticated.memberships.find_by_room_id(params[:room_id])
      @room = membership.room
    end
  end
  
  def create
    if @service = Service.find(params[:service_id]).try(:new)
      @service.create_message(@room, @authenticated, params)
      head :created
    else
      head :not_found
    end
  end
end
