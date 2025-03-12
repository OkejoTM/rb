module Translatable
  extend ActiveSupport::Concern
  included do
    scope :with_translate, -> (locale) { where.not("description_#{locale}": ['', nil]) }
    scope :without_translate, -> (locale) { where("description_#{locale}": ['', nil]) }

    scope :with_autotranslate, -> (locale) { with_translate(locale).where("autotranslated_description_#{locale}": true) }
    scope :without_autotranslate, -> (locale) { where("autotranslated_description_#{locale}": false) }
  end
end
