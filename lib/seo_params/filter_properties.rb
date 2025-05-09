# Агрегирует параметры страницы фильтра недвижимости
module SeoParams
  class FilterProperties < BasicSeoParams
    attr_accessor :type, :template

    def more_options_range_all
      more_options_residential_range.merge(more_options_commercial_range)
    end

    # Параметры "от" "до"
    def more_options_range
      options_by_type =
          case self.type
            when PropertySupertype::COMMERCIAL
              more_options_commercial_range
            when PropertySupertype::RESIDENTIAL
              more_options_residential_range
          else
              {}
          end

      # Получаем список ключей всех параметров фильтра из сео шаблона
      template_options_keys = template.filter_params.keys.map(&:to_sym)
      # Добавляем к стандартным опциям фильтра опции из сео шаблона, которые есть в списке всех опций фильтра
      range_options_keys = (options_by_type.keys + (more_options_range_all.keys & template_options_keys)).uniq

      # Добавляем в список параметров фильтра по умолчанию фильтры из сео шаблона, для которых в сео шаблоне задано значение
      # Если параметр по умолчанию переопределен в сео шаблоне, обновляем его значение
      template.presented_filter_params.each { |k, v| options_by_type[k] = v if range_options_keys.include?(k.to_sym) }

      options_by_type
    end

    private

      def more_options_residential_range
        { level: { css_class: 'formatted_number' },
          level_count: { css_class: 'formatted_number' },
          building_year: {},
          last_repair: {} }
      end

      def more_options_commercial_range
        { rentable_area: { data_unit: I18n.t("squares.sq_m") },
         rental_yield_per_year: {} }
        #rental_yield_per_year: "", rental_yield_per_month: "", min_absolute_income: "", min_amount_of_own_capital: ""
      end

      # Возвращает массив, к значениям arr добавляя "_from" и "_to"
      def process_range_array(arr)
        arr.map { |e| ["#{e}_from", "#{e}_to"] }.flatten
      end
  end
end
