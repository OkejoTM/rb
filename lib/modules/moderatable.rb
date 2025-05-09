module Moderatable
  extend ActiveSupport::Concern

  included do
    scope :moderated, -> { where("#{self.table_name}.moderated = ?", true) }
    scope :not_moderated, -> { where("#{self.table_name}.moderated = ?", false) }

    scope :moderated_choice, -> (option) {
      if option.present?
        if option == 'true'
          moderated
        elsif option == 'false'
          not_moderated
        end
      end
    }
  end
end
