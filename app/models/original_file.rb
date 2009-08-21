class OriginalFile < Video
  self.site = AR_SITE

  def prefix
    filename.split(".").first
  end
end
