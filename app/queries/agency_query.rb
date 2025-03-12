# frozen_string_literal: true

class AgencyQuery
  class << self
    def agencies_for_select
      Agency.all
            .select(:id, :name_ru).order(name_ru: :asc)
            .pluck(:name_ru, :id)
    end
  end
end
