module BasicPage
  extend ActiveSupport::Concern

  include Localizable
  include UserstampModule

  included do
    translate_fields :h1, :title, :meta_description, :description
  end
end
