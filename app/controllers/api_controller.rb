class ApiController < ApplicationController
  prepend_before_filter :authenticate_api_member
  
  private
  
  def authenticate_api_member
    @authenticated = Member.find_by_api_token(params[:api_token])
  end
end
