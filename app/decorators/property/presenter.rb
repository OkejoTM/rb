class Property::Presenter < BasicPresenter
  extend Memoist

  # Содержимое тега h1
  # @return [String] заголовок страницы
  # @example
  #   Property::Presenter.new(Property.first).page_h1
  def page_h1
    if super.present?
      super
    else
      # address_str = [RussianInflect.inflect(self&.country&.title, :genitive),
      address_str = [self&.country&.title_prepositional,
                     *[self&.region, self&.city].compact.map(&:title).uniq].join(', ')

      I18n.t("meta.property_h1",
             type: formatted_type&.capitalize,
             location: address_str,
             location_types: formatted_location_types_substr,
             area: formatted_area_substr)
    end
  end

  # Краткое название страницы в зависимости от языка
  # @return [String] краткое название страницы
  # @example
  #   Property::Presenter.new(Property.first).page_h1
  def short_page_title
    return super if super.present?

    wrapped_property = wrap_property_by_type
    if wrapped_property.present?
      # Получает все кусочки описания
      prefix = wrapped_property.prefix
      room_or_level_count = wrapped_property.room_count_str.presence || wrapped_property.level_count_str
      type = formatted_type
      location_type = formatted_location_type_substr

      # Первое слово делаем с заглавной буквы
      [prefix, room_or_level_count, type].find(&:present?)&.capitalize!

      I18n.t("meta.property_short_title_mk2",
             prefix: prefix,
             room_or_level_count: room_or_level_count,
             type: type,
             location_type: location_type,
             location: address)
    else
      I18n.t("meta.property_short_title",
             type: formatted_type&.capitalize,
             location: address,
             location_type: formatted_location_type_substr)
    end
  end

  # Содержимое тега title
  # @return [String] название страницы
  # @example
  #   Property::Presenter.new(Property.first).page_title
  def page_title
    super.presence || I18n.t("meta.property_title",
                             type: formatted_type,
                             location: address,
                             location_types: formatted_location_types_substr,
                             area: formatted_area_substr,
                             id: id)
  end

  # Содержимое тега meta_description
  # @return [String] описание
  # @example
  #   Property::Presenter.new(Property.first).meta_description
  def meta_description
    super.presence || I18n.t("meta.property_description",
                             type: formatted_type,
                             location: address,
                             location_types: formatted_location_types_substr,
                             features: formatted_features,
                             area: formatted_area_substr,
                             price: formatted_price_substr)
  end

  # Тип продажи недвижимости
  # @return [String] тип продажи недвижимости (аренда/покупка)
  # @example
  #   Property::Presenter.new(Property.first).sale_type
  def sale_type
    return I18n.t(:for_sale, scope: :properties) if self.for_sale
    I18n.t(:for_rent, scope: :properties)
  end

  # Адрес недвижимости
  # @return [String] адрес недвижимости
  # @example
  #   Property::Presenter.new(Property.first).address
  def address
    [self&.city, self&.region, self&.country].compact.map(&:title).uniq.join(', ')
  end

  # Площадь недвижимости
  # @return [String] площадь недвижимости
  # @example
  #   Property::Presenter.new(Property.first).formatted_area
  def formatted_area
    Formatters::AreaFormatter.format_area(self.area, self.area_unit)
  end

  # Площадь участка
  # @return [String] площадь участка
  # @example
  #   Property::Presenter.new(Property.first).formatted_plot_area
  def formatted_plot_area
    Formatters::AreaFormatter.format_area(self.plot_area, self.plot_area_unit)
  end

  # Арендопригодную площадь
  # @return [String] арендопригодная площадь
  # @example
  #   Property::Presenter.new(Property.first).formatted_rentable_area
  def formatted_rentable_area
    Formatters::AreaFormatter.format_area(self.rentable_area, self.rentable_area_unit)
  end

  # Расстояние до ближайшего продуктового магазина
  # @return [String] расстояние до ближайшего продуктового магазина
  # @example
  #   Property::Presenter.new(Property.first).formatted_to_food_stores
  def formatted_to_food_stores
    Formatters::DistanceFormatter.format_distance(self.to_food_stores, self.to_food_stores_unit)
  end

  # Расстояние до подъемника
  # @return [String] расстояние до подъемника
  # @example
  #   Property::Presenter.new(Property.first).formatted_to_ski_lift
  def formatted_to_ski_lift
    Formatters::DistanceFormatter.format_distance(self.to_ski_lift, self.to_ski_lift_unit)
  end

  # Расстояние до пляжа
  # @return [String] расстояние до пляжа
  # @example
  #   Property::Presenter.new(Property.first).formatted_to_beach
  def formatted_to_beach
    Formatters::DistanceFormatter.format_distance(self.to_beach, self.to_beach_unit)
  end

  # Расстояние до моря
  # @return [String] расстояние до моря
  # @example
  #   Property::Presenter.new(Property.first).formatted_to_sea
  def formatted_to_sea
    Formatters::DistanceFormatter.format_distance(self.to_sea, self.to_sea_unit)
  end

  # Расстояние до станции метро
  # @return [String] расстояние до станции метро
  # @example
  #   Property::Presenter.new(Property.first).formatted_to_metro_station
  def formatted_to_metro_station
    Formatters::DistanceFormatter.format_distance(self.to_metro_station, self.to_metro_station_unit)
  end

  # Расстояние до медучреждения
  # @return [String] расстояние до медучреждения
  # @example
  #   Property::Presenter.new(Property.first).formatted_to_medical_facilities
  def formatted_to_medical_facilities
    Formatters::DistanceFormatter.format_distance(self.to_medical_facilities, self.to_medical_facilities_unit)
  end

  # Расстояние до исторического центра города
  # @return [String] расстояние до исторического центра города
  # @example
  #   Property::Presenter.new(Property.first).formatted_to_historical_city_center
  def formatted_to_historical_city_center
    Formatters::DistanceFormatter.format_distance(self.to_historical_city_center, self.to_historical_city_center_unit)
  end

  # Расстояние до границы
  # @return [String] расстояние до границы
  # @example
  #   Property::Presenter.new(Property.first).formatted_to_state_border
  def formatted_to_state_border
    Formatters::DistanceFormatter.format_distance(self.to_state_border, self.to_state_border_unit)
  end

  # Расстояние до вокзала
  # @return [String] расстояние до вокзала
  # @example
  #   Property::Presenter.new(Property.first).formatted_to_railroad_station
  def formatted_to_railroad_station
    Formatters::DistanceFormatter.format_distance(self.to_railroad_station, self.to_railroad_station_unit)
  end

  # Расстояние до ближайшего крупного города
  # @return [String] расстояние до ближайшего крупного города
  # @example
  #   Property::Presenter.new(Property.first).formatted_to_nearest_big_city
  def formatted_to_nearest_big_city
    Formatters::DistanceFormatter.format_distance(self.to_nearest_big_city, self.to_nearest_big_city_unit)
  end

  # Расстояние до аэропорта
  # @return [String] расстояние до аэропорта
  # @example
  #   Property::Presenter.new(Property.first).formatted_to_airport
  def formatted_to_airport
    Formatters::DistanceFormatter.format_distance(self.to_airport, self.to_airport_unit)
  end

  def formatted_location_types
    return unless location_types

    location_types.map(&:title).join(', ')
  end

  def formatted_construction_phase
    return unless construction_phase

    construction_phases[construction_phase]
  end

  # Список полей для карточки недвижимости на странице фильтра
  # @return [Array] список полей недвижимости для карточки недвижимости в фильтре
  def fields_for_tile
    if residential?
      [:area, :plot_area, :level, :level_count, :bedroom_count, :bathroom_count, :room_count]
    elsif commercial?
      [:rentable_area]
    elsif land?
      [:plot_area]
    else
      []
    end.freeze
  end

  # Список основных полей недвижимости
  def fields_for_main_features
    [:area, :plot_area, :level, :level_count, :bedroom_count, :bathroom_count, :room_count].freeze
  end

  # Список полей для блока "Подробнее"
  def fields_for_details
    [:location_types, :building_year, :last_repair, :rental_yield_per_year, :rental_yield_per_month,
     :min_absolute_income, :min_amount_of_own_capital, :rentable_area,
     :to_food_stores, :to_ski_lift, :to_beach, :to_sea, :to_metro_station, :to_medical_facilities,
     :to_historical_city_center, :to_state_border, :to_railroad_station, :to_nearest_big_city, :to_airport,
     :construction_phase].freeze
  end

  def formatted_fields(fields:, limit: 0)
    return {} unless fields

    fields.reduce({}) do |memo, f|
      value = send(f)
      value = value.strftime('%Y') if value.instance_of?(Date)

      if value.present? && value != 0
        formatted_method = "formatted_#{f}"
        formatted_value = send(formatted_method) if respond_to?(formatted_method)

        memo[f] = formatted_value.presence || value
      end

      return memo if limit.positive? && memo.size >= limit
      memo
    end
  end

  MAX_SIMILAR_PROPERTIES = 5

  def similar_properties
    if self.city.present?
      return self.city
                 .properties
                 .for_sale
                 .where(property_type_id: self.property_type_id)
                 .where.not(id: self.id)
                 .first(MAX_SIMILAR_PROPERTIES)
    end
    []
  end

  def moderated_description
    TextModerator.new.remove_censored_words(description)
  end

  # Проверяет в избранном недвижимость или нет
  # @param [Hash] hash - массив, где хранится избранное
  # @param [Symbol] key - ключ в массиве
  # @return [Boolean] - в ибранном эта недвижимость или нет
  def favorite?(hash, key = :favorite)
    !(hash[key].nil?) && JSON.parse(hash[key]).include?(self.id)
  end

  def favorite_css_class(hash, key = :favorite)
    "liked" if favorite?(hash, key)
  end

  def country_path_by_supertype
    country.seo_path(property_supertype)
  end

  memoize :page_h1, :short_page_title, :page_title, :meta_description, :sale_type, :address,
          :formatted_area, :formatted_plot_area, :formatted_rentable_area, :formatted_to_food_stores,
          :formatted_to_ski_lift, :formatted_to_beach, :formatted_to_sea, :formatted_to_metro_station,
          :formatted_to_medical_facilities, :formatted_to_historical_city_center, :formatted_to_state_border,
          :formatted_to_railroad_station, :formatted_to_nearest_big_city, :formatted_to_airport,
          :formatted_location_types, :formatted_construction_phase,
          :fields_for_tile, :fields_for_main_features, :fields_for_details,
          :moderated_description, :favorite?, :favorite_css_class, :country_path_by_supertype

  private

    # Тип недвижимости
    # @return [String] тип недвижимости
    # @private
    # @example
    #   Property::Presenter.new(Property.first).formatted_type
    def formatted_type
      self.property_type&.title&.downcase
    end

    # Тип локации недвижимости
    # @return [String] тип локации недвижимости
    # @private
    # @example
    #   Property::Presenter.new(Property.first).formatted_location_type_substr
    def formatted_location_type_substr
      result = self.location_types&.first&.title&.downcase
      return " #{result}" if result.present?
      ''
    end

    # Типы локаций недвижимости
    # @return [String] типы локаций недвижимости
    # @private
    # @example
    #   Property::Presenter.new(Property.first).formatted_location_types_substr
    def formatted_location_types_substr
      result = self.location_types.map(&:title).join(', ').downcase
      return " #{result}" if result.present?
      ''
    end

    # Подстрока площади недвижимости
    # @return [String] подстрока площади недвижимости
    # @private
    # @example
    #   Property::Presenter.new(Property.first).formatted_area_substr
    def formatted_area_substr
      result = formatted_area
      return ", #{result}" if result.present?
      ''
    end

    # Подстрока стоимости недвижимости
    # @return [String] подстрока стоимости недвижимости
    # @private
    # @example
    #   Property::Presenter.new(Property.first).formatted_price_substr
    # @todo сейчас работает только в валюте по умолчанию
    def formatted_price_substr
      return I18n.t(:price_on_request, scope: :properties) if self.price_on_request?
      ", #{I18n.t(:price, scope: :properties)}: #{Formatters::PriceFormatter.format_money(self.sale_price)}"
    end

    # Особенности недвижимости
    # @return [String] особенности недвижимости
    # @private
    # @example
    #   Property::Presenter.new(Property.first).formatted_features
    def formatted_features
      bedrooms = self.noncommercial_property_attribute&.bedroom_count.to_i
      bedrooms_part =
          if bedrooms > 0
            "#{bedrooms} #{I18n.t(:bathrooms_ablative, scope: :properties)}"
          else
            ""
          end

      bathrooms = self.noncommercial_property_attribute&.bathroom_count.to_i
      bathrooms_part =
          if bathrooms > 0
            "#{bathrooms} #{I18n.t(:bedrooms_ablative, scope: :properties)}"
          else
            ""
          end

      if bedrooms_part.present? && bathrooms_part.present?
        " #{I18n.t(:with, scope: :common)} #{bedrooms_part} #{I18n.t(:and, scope: :common)} #{bathrooms_part}"
      elsif bedrooms_part.present?
        " #{I18n.t(:with, scope: :common)} #{bedrooms_part}"
      elsif bathrooms_part.present?
        " #{I18n.t(:with, scope: :common)} #{bathrooms_part}"
      else
        ''
      end
    end

    # Оборачивает недвижимость в презентер для генерации наименования в соответствии с типом,
    # если такой презентер есть
    # @return [Property::AutoNaming::Presenter] презентер для генерации наименования в соответствии с типом
    def wrap_property_by_type
      presenter = "Property::AutoNaming::#{self.property_type.name_by_id.capitalize}".safe_constantize
      return presenter.new(self) if presenter.is_a?(Class)
      nil
    end

    # Переводы для стадии строительства
    def construction_phases
      {
          Property::CONSTRUCTION_PHASE_NEW => I18n.t(:new_building, scope: :properties),
          Property::CONSTRUCTION_PHASE_OFF_PLAN => I18n.t(:off_plan, scope: :properties),
          Property::CONSTRUCTION_PHASE_RESALE => I18n.t(:resale, scope: :properties)
      }
    end
end
