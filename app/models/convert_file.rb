class ConvertFile < Video
  self.site = AR_SITE

  def s3_name
    "#{id}_#{filename}"
  end
  
  def thumbnails
    thumbnail_count.to_i <= 0 ? [] : thumbnail_count.to_i == 1 ? [thumbnail] : thumbnail
  end
end
