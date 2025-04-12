class Parsers::Vartur::Attributes::PropertyAttributes < Parsers::BaseAttributes

  def locales
    %i[ru en]
  end

  def sale_price_unit
    'USD'
  end

  def h1
    return if response.blank?
    response.at('h2[itemprop="name"]')&.text&.strip
  end

  def breadcrumbs
    return [] if response.blank?
    data = response.css('nav[aria-label="Breadcrumb"] ol li')
    data.map do |li|
      li.at('a')&.text&.strip
    end
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
    parent_area_span = area_element
    return if parent_area_span.blank?

    area_text = parent_area_span.at('span.text-xs')&.text&.strip
    return if area_text.blank?

    area_text.scan(/\d+/).first
  end

  def area_unit
    return if response.blank?
    return Formatters::AreaFormatter::AREA_UNIT_SQ_FT if response.at('span:contains("SQFT")').present?
    return Formatters::AreaFormatter::AREA_UNIT_SQ_M if response.at('span:contains("SQM")').present?
    nil
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

  def moderated
    true
  end

  def parsed
    true
  end

  def is_active
    response.code != "404"
  end

  def property_tags
    return [] if response.blank?

    tags = []
    feature_sections = response.css('.flex.flex-col.mb-3')

    feature_sections.each do |section|
      section.css('.flex.items-center span.text-gray-600.text-sm').each do |tag_span|
        tag_text = tag_span.text.strip
        next if tag_text.blank?

        tags << {
          title_en: tag_text,
          title_ru: tag_text
        }
      end
    end

    tags.uniq { |tag| tag[:title_en] }
  end

  private

    def area_element
      @area_element ||= response && (response.at('span:contains("SQM")')&.parent || response.at('span:contains("SQFT")')&.parent)
    end
end
