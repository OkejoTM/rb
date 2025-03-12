module AgenciesHelper
  def linked_countries(agency)
    if agency.active_countries.present?
      default_countries_count = 5

      and_more =
          if agency.active_countries.count > default_countries_count
            "#{t('common.and_more')} #{agency.active_countries.count - default_countries_count}"
          end
      "#{agency.active_countries.first(default_countries_count).map(&:title).join(', ')} #{and_more}"
    end
  end

  # Показывать ли прямые контакты агентства?
  def show_agency_contacts?(agency)
    # Если с агентством нет договора или пользователь залогинен (наш менеджер)
    # !agency.priority? || user_signed_in?
    user_signed_in? # Временно показываем контакты агентства только залогиненным пользователям
  end
end
