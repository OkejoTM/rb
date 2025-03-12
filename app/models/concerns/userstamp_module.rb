module UserstampModule
  extend ActiveSupport::Concern

  included do
    before_create :update_created_by
    before_update :update_modified_by

    belongs_to :created_by_user, class_name: "User", foreign_key: "created_by", optional: true
    belongs_to :updated_by_user, class_name: "User", foreign_key: "updated_by", optional: true
  end

  # Обновляет кем был создан объект
  # @example
  #   Country.first.update_created_by
  def update_created_by
    self.created_by = current_user_id
  end

  # Обновляет кем был изменен объект
  # @example
  #   Country.first.update_modified_by
  def update_modified_by
    self.updated_by = current_user_id
  end

  private

    # Возвращает id текущего пользователя
    # @return [Integer] id текущего пользователя
    # @private
    # @example
    #   Country.first.current_user_id
    def current_user_id
      User.current_user&.id
    end
end
