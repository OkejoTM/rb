module Admin::BidsHelper
  # Иконка с источником обращения
  def bid_source(bid)
    return '<i class="fas fa-question" title="Неизвестно"></i>'.html_safe if bid.mobile.nil?

    if bid.mobile?
      '<i class="fas fa-mobile-alt" title="Устройство клиента - смартфон"></i>'.html_safe
    else
      '<i class="fas fa-desktop" title="Устройство клиента - ПК"></i>'.html_safe
    end
  end

  # Ссылки на список обращений в relation_name
  # @param relation_name [Symbol] название связи из Property
  def links_to_objects_with_bids(relation_name:)
    objects_with_bids(relation_name: relation_name)
        .map do |obj, count|
          link_to("#{obj.title}: #{count}", "#{bids_path}?#{relation_name}_id=#{obj.id}")
        end
        .join(', ')
        .html_safe
  end

  # h1 страницы списка обращений
  # учитывает название страны, если она задана
  def bids_h1(country = nil, property_supertype = nil)
    result = t(:index, scope: :bids)
    result += " #{property_supertype.title}" if property_supertype.present?
    result += " #{country.title_genitive}" if country.present?
    result
  end

  # Стоимость недвижимости из заданного обращения
  # Учитывает что цена может быть по-запросу
  # или измениться с момента создания обращения
  def bid_sale_price(bid)
    result = Formatters::PriceFormatter.format_price(bid.property, currency: current_currency)

    if bid.price_changed?
      old_price =
        if bid.price_on_request?
          I18n.t(:price_on_request, scope: :properties)
        else
          Formatters::PriceFormatter.format_money(bid.sale_price, currency: bid.sale_price_unit)
        end
      result = "#{result} (#{old_price})"
    end

    result
  end

  def links_to_price_limitted(category)
    count = Bid.send(category).count
    link_to("#{I18n.t(category, scope: :common)}: #{count}",
            "#{bids_path}?category=#{category}")
  end

  private

    # Пары ключ-значение стран с обращениями, отсортированные по убыванию количества обращений,
    # где ключ - relation_name,
    # значение - количество обращений
    # @param relation_name [Symbol] название связи из Property
    def objects_with_bids(relation_name:)
      Bid.preload(property: relation_name)
          .inject([]) do |memo, bid|
            obj = bid.property&.send(relation_name)
            memo << obj if obj.present?
            memo
          end
          .inject({}) { |counter, item| counter[item] ||= 0; counter[item] += 1; counter }
          .sort_by { |_, value| -value }
    end
end
