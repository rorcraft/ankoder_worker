class Profile < ActiveResource::Base
  self.site = AR_SITE

  def add_padding?; add_padding == "true" end
  def keep_aspect?; keep_aspect == "true" end

end
