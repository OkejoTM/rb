module SeoModule
  extend ActiveSupport::Concern
  included do
    include Localizable
    translate_fields :page_title, :page_h1, :meta_description
  end
end
