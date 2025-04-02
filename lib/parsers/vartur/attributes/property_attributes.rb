class Parsers::Vartur::Attributes::PropertyAttributes < Parsers::BaseAttributes

  def locales
    %i[ru en]
  end

  def sale_price_unit
    'USD'
  end

  def country_name_ru
    'Турция'
  end

  def country_name_en
    'Turkey'
  end

  def h1
    return if response.blank?
    response.at('h2[itemprop="name"]')&.text&.strip
  end

  def region
    return if response.blank? || breadcrumbs.size < 5

    breadcrumbs[4].at('a')&.text&.strip
  end

  def city
    return if response.blank? || breadcrumbs.size < 4

    breadcrumbs[3].at('a')&.text&.strip
  end

  def property_type
    return if response.blank? || breadcrumbs.size < 2

    type = breadcrumbs[1].at('a')&.text&.strip
    property_type_mapping[type] || type
  end

  def bathroom_count
    return if response.blank?
    bath_icon = response.at('i.fa-bath')
    return nil if bath_icon.nil?

    text = bath_icon.parent.next.text.strip
    text.scan(/\d+/).first
  end

  def bedroom_count
    return if response.blank?
    bed_icon = response.at('i.fa-bed')
    return nil if bed_icon.nil?

    text = bed_icon.parent&.next&.text&.strip
    text&.scan(/\d+/)&.first
  end

  def area
    return if response.blank?
    icon_parent = response.at('span:contains("SQM")')&.parent
    return if icon_parent.blank?

    area_text = icon_parent.at('span.text-xs')&.text&.strip
    return if area_text.blank?

    area_text.scan(/\d+/).first
  end

  def area_unit
    Formatters::AreaFormatter::AREA_UNIT_SQ_M
  end

  def sale_price
    return if response.blank?
    price_element = response.at('span.text-xl.text-gray-900')
    return nil if price_element.nil?

    price_text = price_element.text.strip
    price_text.gsub(/[^\d]/, '')
  end

  def pictures
    return if response.blank?

    all_images = response.css('img')

    thumbnail_images = all_images.select do |img|
      img['src'] && img['src'].include?('tr=w-150,h-150')
    end

    thumbnail_images.map do |img|
      original_src = img['src'].gsub(/\?tr=w-150,h-150.*$/, '')
      {
        src: original_src,
        alt: img['alt'].to_s
      }
    end.uniq { |img| img[:src] }
  end

  def description
    return if response.blank?
    description_text = response.css('.text-sm.text-gray-600').text.strip
    description_text.split(/\n+/).map(&:strip).reject(&:empty?).join("\n")
  end

  def building_year
    return if response.blank?
    description = response.css('.text-sm.text-gray-600').text
    if match = description.match(/Building Age:\s*(\d+)/)
      match[1]
    end
  end

  def room_count
    return if response.blank?
    text = response.css('.text-sm.text-gray-600').text
    if match = text.match(/Number of Rooms:\s*(\d+)/)
      match[1]
    end
  end

  def property_type_mapping
    @property_type_mapping ||=
      {
        'Land' => 'Land plot'
      }
  end

  def moderated
    true
  end

  def parsed
    true
  end

  def is_active
    response.code != "404"
  end

  private

    def breadcrumbs
      @breadcrumbs ||= response.css('nav[aria-label="Breadcrumb"] ol li')
    end
end
