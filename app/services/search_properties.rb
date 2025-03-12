# module Services
class SearchProperties

  def initialize(params)
    @params = params
  end

  # Поиск недвижимости по заданным параметрам
  def perform
    properties = Property.active_and_moderated.with_associations.for_sale
    modified_params = convert_currency_if_present(@params.deep_dup)
    modified_params = query_to_location(modified_params)

    Property.filter(properties, PropertiesFilterUrlGenerator.reject_empty_params(modified_params))
        .preload(:agency)
        .order('agencies.has_contract': :desc)
  end

  private

    # Конвертировать цены, если
    def convert_currency_if_present(params)
      if (params[:price_from].present? || params[:price_to].present?) &&
          (params[:currency].present? && params[:currency] != CurrencyRate::DEFAULT_CURRENCY)
        if params[:price_from].present?
          params[:price_from] = CurrencyConverter.convert(value: params[:price_from].to_i,
                                                          from: params[:currency],
                                                          to: CurrencyRate::DEFAULT_CURRENCY)
        end
        if params[:price_to].present?
          params[:price_to] = CurrencyConverter.convert(value: params[:price_to].to_i,
                                                        from: params[:currency],
                                                        to: CurrencyRate::DEFAULT_CURRENCY)
        end
      end
      params
    end

    def query_to_location(params)
      # Если есть полнотекстовый запрос и не задано ни одной локации
      if params[:query].present? && [params[:country_id], params[:region_id], params[:city_id]].compact.blank?
        ftp = FullTitleParser.new
        ftp.parse_full_title(params[:query])

        params[:city_id] = ftp.city.id if ftp.city.present?
        params[:region_id] = ftp.region.id if ftp.region.present?
        params[:country_id] = ftp.country.id if ftp.country.present?
      end
      params
    end
end
# end
