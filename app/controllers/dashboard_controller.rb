class DashboardController < ApplicationController
  def index
    if current_user.is_grantee?
      redirect_back_or_default grantee_portal_index_path
    else
      render :index, :layout => nil
    end
  end
end
