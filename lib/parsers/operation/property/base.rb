module Parsers::Operation::Property::Base

  # Pictures

  def check_pictures(pictures_attrs, pictures: [])
    new_pictures = []
    return new_pictures if pictures.blank? && pictures_attrs.blank?

    filtered = filter_corrupted_picture(pictures_attrs)

    # remove all
    deleted_pics = mark_deleted_pictures(filtered, pictures)
    new_pictures.concat(deleted_pics)

    # add new
    new_pics = add_not_existed_pictures(filtered, pictures)
    new_pictures.concat(new_pics)

    new_pictures
  end

  def filter_corrupted_picture(picture_links)
    picture_links.filter do |picture_link|
      Parser::ParserUtils.img_exist?(picture_link[:src])
    end
  end

  def mark_deleted_pictures(pictures_attrs, pictures)
    deleted_pics = []
    pictures.each do |picture|
      # check if name of picture is in any of links
      pic_exist = pictures_attrs.any? { |picture_attrs| picture.pic&.file&.filename&.in?(picture_attrs[:src]) }

      deleted_pics.push(id: picture.id, _destroy: true) unless pic_exist
    end
    deleted_pics
  end

  def add_not_existed_pictures(pictures_attrs, pictures)
    new_pictures = []

    pictures_attrs.each do |picture_attrs|
      pic = pictures.find { |picture| picture.pic&.file&.filename&.in?(picture_attrs[:src]) }
      next if pic.present?

      new_pictures.push(remote_pic_url: picture_attrs[:src], description: picture_attrs[:alt])
    end

    new_pictures
  end

  # Location finders

  def find_country(countries, attributes, locales)
    if countries.present?
      countries.find { |c| locales.any? { |l| c.send(:"title_#{l}") == attributes[:"country_name_#{l}"] } }
    else
      Country.where(
        'title_ru ILIKE :title_ru or title_en ILIKE :title_en',
        title_ru: attributes[:country_name_ru],
        title_en: attributes[:country_name_en]
      ).select(:id)
       .limit(1)
       .last
    end
  end

  def find_region(regions, attributes, locales)
    if regions.present?
      regions.find do |region|
        next if region.country_id != attributes[:country_id]

        locales.any? do |l|
          region_name = attributes[:"region_#{l}"]
          next false if region_name.blank?

          region.send(:"title_#{l}").downcase == region_name.downcase
        end
      end
    else
      Region.where(
        'title_ru ILIKE :title_ru or title_en ILIKE :title_en',
        title_ru: attributes[:region_ru],
        title_en: attributes[:region_en]
      ).select(:id)
       .last
    end
  end

  def find_city(cities, attributes, locales)
    if cities.present?
      cities.find do |c|
        locales.any? do |l|
          city_name = attributes[:"city_#{l}"]
          next false if city_name.blank?

          c.send(:"title_#{l}").downcase == city_name.downcase
        end
      end
    else
      City.where(
        'title_ru ILIKE :title_ru or title_en ILIKE :title_en',
        title_ru: attributes[:city_ru],
        title_en: attributes[:city_en]
      ).select(:id)
       .last
    end
  end

  def find_city_by_alternate_name(attributes)
    city_name = attributes[:city_en]
    region_id = attributes[:region_id]

    city_alternates = AlternateName.where("lower(alternate_name) = lower(?)", city_name)
    matching_city_ids = city_alternates.pluck(:geoname_id)
    cities = City.where(id: matching_city_ids)

    cities = cities.where(region_id: region_id) if region_id.present?
    cities.first
  end

  def find_region_by_alternate_name(attributes)
    region_name = attributes[:region_en]
    country_id = attributes[:country_id]

    region_alternates = AlternateName.where("lower(alternate_name) = lower(?)", region_name)
    matching_region_ids = region_alternates.pluck(:geoname_id)
    regions = Region.where(id: matching_region_ids)

    regions = regions.where(country_id: country_id) if country_id.present?
    regions.first
  end

  # Property

  def find_property(property_types, attributes, locales)
    if property_types.present?

      property_types.find do |c|
        locales.any? do |l|
          next false if attributes[:"property_type_#{l}"].blank?

          c.send(:"title_#{l}").match?(/#{attributes[:"property_type_#{l}"]}/i)
        end
      end

    else
      # long request
      PropertyType.where(
        'title_ru ILIKE :title_ru or title_en ILIKE :title_en',
        title_ru: "%#{attributes[:property_type_ru]}%",
        title_en: "%#{attributes[:property_type_en]}%"
      ).select(:id)
       .last
    end
  end

  # Commercial property attributes

  def commercial_property_attribute_hash(property_attrs)
    {
      rental_yield_per_year: property_attrs[:rental_yield_per_year],
      rental_yield_per_year_unit: property_attrs[:rental_yield_per_year_unit]
    }
  end

  # Noncommercial property attributes

  def noncomercial_property_hash(property_attrs)
    {
      level: property_attrs[:level],
      level_count: property_attrs[:level_count],
      property_id: property_attrs[:property_id],
      bathroom_count: property_attrs[:bathroom_count],
      bedroom_count: property_attrs[:bedroom_count]
    }
  end

  # PropertyTags

  def check_property_tags(property_tags, property_tag_attrs, all_property_tags)
    # Оставляем теги, которые есть в полученных с сайта тегах
    existed_tags = property_tags&.reduce([]) do |result, tag|

      is_found = property_tag_attrs.any? do |attr|
        compare_tags(tag, attr)
      end

      next result unless is_found

      result.push(tag)
    end

    existed_tags ||= []

    # добавить новые теги, которые нужно создать
    tags_for_create = property_tag_attrs&.reduce([]) do |result, tag_attr|

      # Проходим по всем существующим тегам и пытаемся использовать их
      existed_tag = all_property_tags.find do |tag|
        compare_tags(tag, tag_attr)
      end

      if existed_tag.present?
        existed_tags.push(existed_tag)
        next result
      end

      result.push(
        title_ru: tag_attr[:title_ru],
        title_en: tag_attr[:title_en],
        is_active: true,
        moderated: false,
        property_tag_category_id: PropertyTagCategory::COMMON_GROUP
      )
    end

    {
      property_tag_ids: existed_tags.map(&:id).uniq,
      property_tags_attributes: tags_for_create || []
    }
  end

  def compare_tags(property_tag, tag_attrs)
    original_names = locales.map { |locale| property_tag.send("title_#{locale}") }
    aliases = property_tag.property_tag_aliases.map(&:name)
    parsed_tag_names = locales.map { |locale| tag_attrs[:"title_#{locale}"] }

    tag_names = original_names.concat(aliases)

    tag_names.any? do |tag_name|
      parsed_tag_names.any? do |tag_attr|
        tag_attr.downcase.in?(tag_name.downcase)
      end
    end
  end

  protected

    def permitted_params(params)
      # Имейте в виду порядок property_tag_ids и property_tags_attributes важен
      # Если property_tag_ids будут идти после property_tags_attributes,
      # то property_tag_ids перезапишут property_tags_attributes
      # Если property_tags_attributes идет после property_tag_ids
      # то мы получаем оба набора тегов в сущности
      acceptable_params = subject_class.attribute_names.deep_dup.map(&:to_sym).push(
        :commercial_property_attribute_attributes,
        :noncommercial_property_attribute_attributes,
        :pictures_attributes,
        :property_tag_ids,
        :property_tags_attributes
      )

      params.slice(*acceptable_params)
    end

    def subject_class
      ::Property
    end
end
