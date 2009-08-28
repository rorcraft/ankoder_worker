class HController < ApplicationController
  # H for Hell.
  # GTH for "go to hell".
  # this controller is prepared for unwelcome traffic.
  def gth; head :bad_request end

end
