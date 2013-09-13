class Song < ActiveRecord::Base
  has_attached_file :upload
  belongs_to :band

  validates_attachment_content_type :upload, content_type: %w(audio/mpeg audio/ogg audio/mp3 audio/mp4 audio/vnd.wave audio/x-ms-wma)
  validate :dont_exceed_limit

  include Rails.application.routes.url_helpers

  def make_primary_for_band
    band.songs.each { |s| s.update_attribute 'primary_song', false }
    update_attribute 'primary_song', true
  end

  def to_jq_upload
    {
      "id"   => id,
      "primary_song" => primary_song,
      "name" => read_attribute(:upload_file_name),
      "size" => read_attribute(:upload_file_size),
      "url" => upload.url,
      "content_type" => upload_content_type, 
      "delete_url" => upload_path(:id => id, type: 'song'),
      "download_url" => download_upload_path(:id => id, type: 'song')
    }
  end

  def to_s
    upload_file_name.gsub /.\w+$/, ''
  end


  private

  def dont_exceed_limit
    errors.add(:upload, 'Only 3 songs allowed') if self.band.songs.count >= 3 
  end
end
