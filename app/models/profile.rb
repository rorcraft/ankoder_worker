class Profile < ActiveResource::Base
  self.site = AR_SITE

  def add_padding?; add_padding == "true" end
  def keep_aspect?; keep_aspect == "true" end
  def watermark_transparent?; watermark_transparent == "true" end

  def watermark_ratio
    @watermark_ratio ||= watermark_size.to_f/100.0
  end

end
