class ConvertFile < Video
  self.site = AR_SITE
  
  def thumbnails
    thumbnail_count.to_i <= 0 ? [] : thumbnail_count.to_i == 1 ? [thumbnail] : thumbnail
  end
end
