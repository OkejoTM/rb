module ApplicationHelper
  include Utils::Html
  include OwlViewHelper
  include MetaTagHelper

  FORBIDDEN_IPS_FOR_METRIKA = [
    '213.80.134.114',
    '178.155.72.47'
  ]

  # Генерирует на основе заданного url альтернативную ссылку на другом языке
  # @param original_url [String] исходная ссылка
  # @return [String] тег link для текущую страницу на другом языке
  # @example
  #   https://propimo.com => https://propimo.com/en
  #   https://propimo.com/en => https://propimo.com/ru
  #   https://propimo.com/en/ => https://propimo.com/ru/
  #   https://propimo.com/en/residential => https://propimo.com/ru/residential
  def alternate_link(original_url)
    alt_locale = I18n.available_locales.reject { |locale| locale == I18n.locale }.first
    alt_url = BasicUri.alternate_url(original_url, alt_locale)
    "<link rel=\"alternate\" hreflang=\"#{alt_locale}\" href=\"#{alt_url}\"/>".html_safe
  end

  # Проверяет совпадает ли текущая локаль с +locale+
  def locale?(locale)
    I18n.locale == locale
  end

  # Установить мета тег title на странице
  def title(page_title)
    content_for(:title) { page_title }
  end

  def danger_help_block(object_id, default_text: nil, css_class: nil)
    "<span id='#{object_id}' class='help-block text-danger #{css_class}' style='display: none;'>#{default_text}</span>".html_safe
  end

  def format_count_properties(count)
    number_with_delimiter(count, separator: " ")
  end

  # Склонение названия объявлений о продаже недвижимости
  def advert_pluralize(count)
    Russian::p(count,
               t(:object, scope: :properties),
               t(:objects_dative, scope: :properties),
               t(:objects_genitive, scope: :properties))
  end

  def days_ago_pluralize(property)
    days = (Date.today - property.created_at.to_date).to_i

    ago = Russian::p(days,
                     t(:day_ago, scope: :properties),
                     RussianInflect.inflect(t(:days_ago, scope: :properties), :dative),
                     RussianInflect.inflect(t(:days_ago, scope: :properties), :genitive))

    "#{days} #{ago}"
  end

  def navbar_active_menu(request, url)
    'class="current"'.html_safe if request.fullpath.include?(url)
  end

  def description_show_more?(description, length = 350)
    description.present? && description.length > length
  end

  def locations_show_more?(locations, count = 36)
    locations.present? && locations.count > count
  end

  def countries_show_more?(countries, count = 36)
    countries.present? && countries.values.flatten.count > count
  end

  def language_switcher
    res = ''
    I18n.available_locales.each do |loc|
      link =
        if I18n.locale != loc
          link = link_to(loc.to_s.upcase,
                         BasicUri.alternate_url(request.original_url, loc),
                         class: "change-locale",
                         id: "locale_#{loc}")
          "<span class=\"sign-in locale\" >#{link}</span>".html_safe
        else
          "<span class=\"sign-in locale current\">#{loc.to_s.upcase}</span>".html_safe
        end

      res += link

      if loc != I18n.available_locales.last
        res += '<span class="sign-in locale">&nbsp;|&nbsp;</span>'.html_safe
      end
    end

    res.html_safe
  end

  def page_number_substr(page_number)
    return " - #{t(:page, scope: :common)} #{page_number}" if page_number.present? && page_number > 1
    ''
  end

  def page_count_objects(count_objects)
    "#{format_count_properties(count_objects)} #{advert_pluralize(count_objects)}"
  end

  def page_count_of_size(page_number, page_size, total_count)
    first_object_index = (page_number - 1) * page_size
    max_total_count = first_object_index + page_size

    number_from = first_object_index + 1
    number_to = max_total_count > total_count ? total_count : max_total_count
    "#{number_from}&nbsp;-&nbsp;#{number_to} #{t(:of, scope: :common)} #{total_count}#{page_number_substr(page_number)}".html_safe
  end

  def found_listings(count)
    t("filter.found_listings", count: count)
  end

  # Разметка алерта отключенной сущности
  # @param [Symbol] obj_type ключ в языковом файле для получения строки с сообщением алерта
  def disabled_obj_alert(obj_type)
    <<-HTML
      <div class="alert alert-danger" role="alert" id="disabled-property">
        <strong>#{t(:alert_not_active, scope: :properties)}</strong> #{t(:alert_not_active_description, scope: obj_type)}
      </div>
    HTML
  end

  # Для формирования ссылки для пагинации тега link_to
  def path_for_link(uri, page_number, params)
    uri.present? ? uri.change_page_number(page_number) : params.merge(page: page_number)
  end

  # Разрешен ли ip для попадания в метрику
  def allowed_ip_for_metrika?(ip)
    FORBIDDEN_IPS_FOR_METRIKA.exclude?(ip)
  end

  def current_currency
    params[:currency] || session[:currency] || CurrencyRate::DEFAULT_CURRENCY
  end

  # Генерирует иконку страны
  def country_icon(country, **html_options)
    style = "style='#{html_options[:style]}'" if html_options[:style].present?
    "<span class='flag-icon flag-icon-#{country.iso_alpha2.downcase} #{html_options[:class]}' #{style}></span>".html_safe
  end

  def date_format(date, format_type: :article_date_format)
    # distance_of_time_in_words_to_now(date)
    date_formats = {
      article_date_format: "%-d %B %Y",
      simple_format: "%T %F", # 20:15:16 2017-12-01
      short_date_time_format: "%d.%m.%y %H:%M", # 31.10.19 16:22
      file_name_format: "%d_%m_%y", # 31_01_20
    }

    format = date_formats.fetch(format_type)

    if I18n.locale == :ru
      Russian::strftime(date, format)
    else
      date.strftime(format)
    end
  end

  def frontend_edit_icon(edit_path)
    if current_user.present? && edit_path.present?
      "<a href='#{edit_path}'><small><i class='fas fa-edit'></i></small></a>".html_safe
    end
  end

  def continent_name(continent)
    I18n.t("continents.#{continent}")
  end

  # Генерирует строку с полнотекстовым поиском
  def fulltext_search(query, style: '')
    text_field = text_field_tag :query,
                                query,
                                class: 'form-control typeahead ico-01',
                                placeholder: t(:search_placeholder, scope: :banner),
                                # autofocus: true,
                                required: true,
                                autocomplete: 'off',
                                style: style

    "<i id='loading-icon' class='fas fa-spin fa-spinner loading-icon'></i>#{text_field}".html_safe
  end

  # Добавляет к переводу звездочку в конце (полезно для обязательных полей)
  def translate_with_asterisk(translation_path)
    "#{I18n.t(translation_path)} *"
  end

  # @param [String] message
  # @return [String] html для сообщения успешной отправки сообщения
  def notification_success(message)
    <<-HTML
      <div class='notification success'>#{message}</div>
    HTML
  end

  def object_from_hash(hash_obj)
    OpenStruct.new(hash_obj)
  end

  def loader_block(**html_options)
    id = "id='#{html_options[:id]}'" if html_options[:id].present?
    <<-HTML.html_safe
      <div class="text-center">
        <img #{id} src="#{asset_pack_path("images/loader.gif")}">
      </div>
    HTML
  end

  def map_point_link(latitude, longitude)
    "https://maps.google.com/maps?q=#{latitude},#{longitude}&hl=#{I18n.locale}"
  end

  def get_favorites
    JSON.parse(cookies[:favorite] || "[]")
  end

  def get_compare_properties_ids
    JSON.parse(cookies[:compare] || "[]")
  end

  def get_compare_properties
    ids = get_compare_properties_ids
    Property.where(id: ids)
      .order(Arel.sql("array_position(array#{ids}, CAST(properties.id AS integer))"))
  end
end
