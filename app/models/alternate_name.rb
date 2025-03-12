# == Schema Information
#
# Table name: alternate_names
#
#  id             :bigint           not null, primary key
#  alternate_name :string(200)      indexed
#  continent      :string(20)
#  iso_language   :string(80)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  geoname_id     :bigint           indexed, indexed
#

class AlternateName < ApplicationRecord
  belongs_to :country, foreign_key: 'geoname_id', optional: true
  belongs_to :cities, foreign_key: 'geoname_id', optional: true
  belongs_to :regions, foreign_key: 'geoname_id', optional: true
end
