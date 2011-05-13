class LoisController < ApplicationController
  skip_before_filter :require_user, :only => [:new, :create]
  include FluxxLoisController
# #  before_filter :require_user, :only => :destroy
# #  skip_before_filter :verify_authenticity_token, :only => [:new, :create]
# 
#   def new
#     response.headers['fluxx_template'] = 'loi'
#   end
# 
#   def create
#     @loi = Loi.new(params["loi"]).save
#   end

end