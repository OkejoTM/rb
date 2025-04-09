class Parsers::Vartur::Operations::Property::Upsert
  include ActiveModel::Validations
  include Parsers::Operation::Property::Base

  LOCALES = Parsers::Vartur::Schema::LOCALES

  attr_reader :result

  def initialize(agency = nil)
    @agency = agency
  end

  def call(property_url, attributes)
    return false unless valid?
    @result = find_existing(property_url)

    if @result.new_record?
      add_country(attributes)
      add_region(attributes)
      add_city(attributes)
      add_property_type(attributes)
      add_agency(attributes)
      add_external_link(property_url, attributes)
    end

    update_pictures(result, attributes)
    update_noncommercial_attributes(result, attributes)
    update_property_tags(result, attributes)
    save!(@result, attributes)
    true
  rescue => e
    errors.add(:base, e.message)
    false
  end

  private

    def find_existing(property_url)
      result = ::Property.includes(:country,
                                   :region,
                                   :city,
                                   :agency,
                                   :property_type,
                                   :noncommercial_property_attribute,
                                   :pictures,
                                   :property_tags)
                         .where(external_link: property_url)
                         .first

      result.presence || ::Property.new
    end

    def add_country(attributes)
      country = find_country_from_breadcrumbs(attributes)

      attributes[:country_id] = country&.id
    end

    def find_country_from_breadcrumbs(attributes)
      breadcrumbs = attributes[:breadcrumbs]
      return if breadcrumbs.blank?

      search_attrs = {}
      breadcrumbs.each do |crumb|
        next if crumb.blank?

        LOCALES.each do |locale|
          search_attrs[:"country_name_#{locale}"] = crumb
        end

        country_search = Parsers::Operation::Country::Search.new(search_attrs, LOCALES)
        if country_search.call
          return country_search.result
        end
      end
      nil
    end

    def add_region(attributes)
      region = find_region_from_breadcrumbs(attributes)

      attributes[:region_id] = region&.id
      attributes[:region_name_en] = region&.title_en
      attributes[:region_name_ru] = region&.title_ru
    end

    def find_region_from_breadcrumbs(attributes)
      breadcrumbs = attributes[:breadcrumbs]
      return if attributes[:country_id].blank? || breadcrumbs.blank?

      search_attrs = { country_id: attributes[:country_id] }
      breadcrumbs.each do |crumb|
        next if crumb.blank?

        LOCALES.each do |locale|
          search_attrs[:"region_#{locale}"] = crumb
        end

        region_search = Parsers::Operation::Region::Search.new(search_attrs, LOCALES)
        if region_search.call
          return region_search.result
        end
      end
      nil
    end

    def add_city(attributes)
      city = find_city_from_breadcrumbs(attributes)

      attributes[:city_id] = city&.id
      attributes[:city_name_en] = city&.title_en
      attributes[:city_name_ru] = city&.title_ru
    end

    def find_city_from_breadcrumbs(attributes)
      breadcrumbs = attributes[:breadcrumbs]
      return if breadcrumbs.blank?

      search_attrs = { region_id: attributes[:region_id] }
      breadcrumbs.each do |crumb|
        next if crumb.blank?

        LOCALES.each do |locale|
          search_attrs[:"city_#{locale}"] = crumb
        end

        city_search = Parsers::Operation::City::Search.new(search_attrs, LOCALES)
        if city_search.call
          return city_search.result
        end
      end
      nil
    end

    def add_property_type(attributes)
      property_type = find_property_type_from_breadcrumbs(attributes)
      attributes[:property_type_id] = property_type&.id || ::PropertyType::OTHER
    end

    def find_property_type_from_breadcrumbs(attributes)
      breadcrumbs = attributes[:breadcrumbs]
      return if breadcrumbs.blank?

      search_attrs = {}
      breadcrumbs.each do |crumb|
        next if crumb.blank?

        LOCALES.each do |locale|
          search_attrs[:"property_type_#{locale}"] = property_type_mapping[crumb] || crumb
        end

        property_type = find_property_type(search_attrs)
        return property_type if property_type.present?
      end
      nil
    end

    def property_type_mapping
      @property_type_mapping ||=
        {
          'Land' => 'Land plot'
        }
    end

    def add_agency(attributes)
      attributes[:agency_id] = @agency.id
    end

    def add_external_link(link, attributes)
      attributes[:external_link] = link
    end

    def update_pictures(property, attributes)
      if attributes.has_key?(:pictures)
        attributes[:pictures_attributes] = check_pictures(attributes[:pictures], pictures: property.pictures)
      end
    end

    def update_noncommercial_attributes(property, attributes)
      has_property_attrs = attributes.keys.any? do |key|
        key.in?(%i[level level_count property_id bathroom_count bedroom_count])
      end
      if has_property_attrs
        attributes[:noncommercial_property_attribute_attributes] = check_noncomercial_property_attribute(
          property.noncommercial_property_attribute,
          attributes
        )
      end
    end

    def check_noncomercial_property_attribute(noncommercial, property_attrs)
      noncommercial_attrs = noncomercial_property_hash(property_attrs)
      noncommercial_attrs[:id] = noncommercial.id if noncommercial.present?
      noncommercial_attrs
    end

    def update_property_tags(property, attributes)
      if attributes.has_key?(:property_tags) && attributes[:property_tags].present?
        # Загружаем все существующие теги
        all_property_tags = ::PropertyTag.includes(:property_tag_aliases).all.to_a

        tag_attrs = check_property_tags(
          property.property_tags,
          attributes[:property_tags],
          all_property_tags,
          LOCALES
        )

        # Добавляем атрибуты в основные атрибуты объекта
        attributes[:property_tag_ids] = tag_attrs[:property_tag_ids] if tag_attrs[:property_tag_ids].present?
        attributes[:property_tags_attributes] = tag_attrs[:property_tags_attributes] if tag_attrs[:property_tags_attributes].present?
      end
    end

    def save!(result, attributes)
      permitted_attrs = permitted_params(attributes)

      # Разделяем атрибуты и изображения
      pictures_attrs = permitted_attrs.delete(:pictures_attributes)

      # Сохраняем основную сущность
      result.assign_attributes(permitted_attrs)

      if result.save
        # Если есть изображения, пробуем их добавить одно за другим
        if pictures_attrs.present?
          pictures_attrs.each do |pic_data|
            Picture.create(
              imageable: result,
              description: pic_data[:description],
              remote_pic_url: pic_data[:remote_pic_url]
            )
          end
        end

        result
      else
        raise result&.errors&.messages&.to_json
      end
    end

end
