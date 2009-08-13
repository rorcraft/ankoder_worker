class Profile < ActiveResource::Base
  self.site = AR_SITE

  def add_padding?
    add_padding == "true"
  end

end
