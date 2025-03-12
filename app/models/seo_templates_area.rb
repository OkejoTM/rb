# == Schema Information
#
# Table name: seo_templates_areas
#
#  id              :bigint           not null, primary key
#  locatable_type  :string           indexed => [locatable_id], indexed => [locatable_id], indexed => [locatable_id, seo_template_id]
#  locatable_id    :bigint           indexed => [locatable_type], indexed => [locatable_type], indexed => [seo_template_id, locatable_type]
#  seo_template_id :bigint           indexed, indexed => [locatable_id, locatable_type]
#

class SeoTemplatesArea < ApplicationRecord
  belongs_to :locatable, polymorphic: true
  belongs_to :seo_template
end
