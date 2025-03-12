module SeoTemplatable
  extend ActiveSupport::Concern
  included do
    has_many :seo_templates_areas, as: :locatable, dependent: :nullify
    has_many :seo_templates, through: :seo_templates_areas

    scope :with_seo_template, -> (seo_template_id) {
      joins(:seo_templates_areas).where(seo_templates_areas: { seo_template_id: seo_template_id }) #if seo_template_id != ""
    }

    after_save :touch_seo_templates

    def touch_seo_templates
      seo_templates.map(&:touch)
    end
  end
end
