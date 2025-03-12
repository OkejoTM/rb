# == Schema Information
#
# Table name: pictures
#
#  id             :bigint           not null, primary key
#  description    :string
#  imageable_type :string           indexed => [imageable_id]
#  pic            :string
#  priority       :integer          default(0)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  imageable_id   :bigint           indexed => [imageable_type]
#

class Picture < ApplicationRecord
  mount_base64_uploader :pic, PictureUploader
  belongs_to :imageable, polymorphic: true, optional: true

  scope :temporary, -> { where(imageable_type: nil, imageable_id: nil) }

  def cropped_picture_url
    if File.exist?(pic.current_path.gsub('.', 't.'))
      return pic.url.gsub('.', 't.')
    end

    image = MiniMagick::Image.open(pic.current_path)
    crop_params = "#{image.width}x#{image.height - 15}+0+0"
    cropped_image = image.crop(crop_params)

    new_file_path = pic.current_path.gsub('.', 't.')
    cropped_image.write(new_file_path)

    pic.url.gsub('.', 't.')
  end
end
