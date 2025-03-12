class PropertiesFilterUrlGenerator

  def initialize(params)
    @params = params
  end

  class << self
    # Удаляет элемент из params, если key заканчиваются на _to или _from и значение по такому ключу пустое
    def reject_empty_params(params)
      params.reject { |key, value| key.match?(/.*_(from|to)$/) && value.blank? }
    end

    # Удаляет элемент из params, если key заканчиваются на _from и значение по такому ключу равно "0"
    def reject_zeroed_params(params)
      zeroed_params = %w(bathrooms bedrooms page sort_by_price type)
      params.reject { |key, value| (key.match?(/.*_from$/) || zeroed_params.include?(key)) && value == "0" }
    end

    # Удаляет элементы из params, которые не должны участвовать в формировании GET параметров
    def reject_useless_params(params)
      params.reject { |key, _| %w(country_id region_id city_id residential commercial land property_supertype_id property_supertype).include?(key) }
    end

    # Удаляет элемент с именем param из params, если его значение равно default_value
    def reject_default_params(params, param, default_value)
      params.reject { |key, value| key == param && value == default_value }
    end
  end

  def perform
    location_path = FullTitleParser.new.get_location_path(@params[:query]) if @params[:query].present?
    supertype_slug = PropertySupertype.slug_by_id(@params[:property_supertype_id].to_i) if @params[:property_supertype_id].present?

    path =
        if location_path.present? && supertype_slug.present?
          "#{location_path}/#{supertype_slug}"
        elsif supertype_slug.present?
          path_by_supertype(@params[:property_supertype_id])
        elsif location_path.present?
          location_path
        end

    # вычислить гет-параметры
    filter_params = @params.slice(Property.filter_params)
                        .merge(@params.permit(:currency))
                        .merge(@params.permit(:page).slice(:page))

    filter_params = PropertiesFilterUrlGenerator.reject_empty_params(filter_params)
    filter_params = PropertiesFilterUrlGenerator.reject_zeroed_params(filter_params)
    filter_params = PropertiesFilterUrlGenerator.reject_useless_params(filter_params)

    params_default_values.each do |param_key, default_value|
      filter_params = PropertiesFilterUrlGenerator.reject_default_params(filter_params, param_key, default_value)
    end

    # склеить локация + супертип + гет параметры
    return "#{path}?#{filter_params.permit!.to_param}" if filter_params.present?
    "#{path}"
  end

  private

    def path_by_supertype(supertype_id)
      case supertype_id.to_i
        when PropertySupertype::COMMERCIAL
          UrlsHelper.commercial_path
        when PropertySupertype::RESIDENTIAL
          UrlsHelper.residential_path
        when PropertySupertype::LAND
          UrlsHelper.land_path
      end
    end

    def params_default_values
      {
          'page' => 1,
          'currency' => CurrencyRate::DEFAULT_CURRENCY
      }
    end
end
