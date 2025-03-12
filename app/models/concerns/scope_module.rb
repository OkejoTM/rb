module ScopeModule
  extend ActiveSupport::Concern

  included do
    class << self
      def scopes_with_value(*fields)
        fields.each do |s|
          scope s, -> (value) { where(s => value) }
        end
      end
    end
  end
end
