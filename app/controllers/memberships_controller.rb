class MembershipsController < ApplicationController
  allow_access(:authenticated) { @membership = @authenticated.memberships.find_by_id(params[:id]) }
  
  def update
    @membership.update_attributes(params[:membership])
    head :no_content
  end
end
