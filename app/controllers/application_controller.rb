# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  #protect_from_forgery # only scaler can see workers

  before_filter :workflow_required
  include Spawn

  def workflow_required
    authenticate_or_request_with_http_basic do |username, password|
      username == "workflow" && password == "r0rcr4ft"
    end
  end
end
