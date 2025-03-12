module Localizable
  extend ActiveSupport::Concern
  included do
    class << self
      def translate_fields(*attrs)
        attrs.each do |field|
          define_method(field) do
            instance_eval("#{field}_#{I18n.locale.to_s}")
          end
        end
      end
    end
  end
end
