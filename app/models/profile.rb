class Profile < ActiveResource::Base
  self.site = AR_SITE

  def add_padding?; add_padding == "true" end
  def keep_aspect?; keep_aspect == "true" end
  def watermark_transparent?; watermark_transparent == "true" end
  def watermark_mode; watermark_transparent? ? 0 : 1 end

  def watermark_ratio; @watermark_ratio ||= watermark_size.to_f/100.0 end
  def watermark_top_ratio; @watermark_top_ratio ||= watermark_top.to_f/100.0 end
  def watermark_left_ratio; @watermark_left_ratio ||= watermark_left.to_f/100.0 end

  def watermark_effective_bgcolor
    watermark_transparent? ? watermark_bgcolor || "808080" : "000000"
  end

end
