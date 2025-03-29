class Parsers::Vartur::Operations::Property::Upsert
  include ActiveModel::Validations
  include Parsers::Operation::Property::Base

  LOCALES = Parsers::Vartur::Schema::LOCALES

  attr_reader :entity

  def initialize(agency = nil)
    @agency = agency
  end

  def call(property_url, attributes)
    return false unless valid?
    @entity = find_existing(property_url)

    if @entity.new_record?
      add_country(attributes)
      add_region(attributes)
      add_city(attributes)
      add_property_type(attributes, property_types: property_types_preload)
      add_agency(attributes)
      add_external_link(property_url, attributes)
    end

    pictures(entity, attributes)
    noncommercial_property_attribute(entity, attributes)
    save(@entity, attributes)
    true
  rescue => e
    errors.add(:base, e.message)
    false
  end

  private

    def find_existing(property_url)
      entity = ::Property.includes(:country,
                                   :region,
                                   :city,
                                   :agency,
                                   :property_type,
                                   :noncommercial_property_attribute,
                                   :pictures,
                                   :property_tags)
                         .where(external_link: property_url)
                         .first

      entity.presence || ::Property.new
    end

    def add_country(attributes)
      country_search = Parsers::Operation::Country::Search.new(attributes, LOCALES)
      country_search.call
      country = country_search.result

      attributes[:country_id] = country.id
    end

    def add_region(attributes)
      attributes[:region_en] = attributes[:city_en] if attributes[:region_en].blank?
      region_search = Parsers::Operation::Region::Search.new(attributes, LOCALES)
      region_search.call
      region = region_search.result

      return attributes if region.blank?

      attributes[:region_id] = region.id
      attributes[:region_name_en] = region.title_en
      attributes[:region_name_ru] = region.title_ru
    end

    def add_city(attributes)
      city = find_city(attributes)
      if city.blank?
        city_search = Parsers::Operation::City::Search.new(attributes, LOCALES)
        city_search.call
        city = city_search.result
      end

      return attributes if city.blank?

      attributes[:city_id] = city.id
      attributes[:city_name_en] = city.title_en
      attributes[:city_name_ru] = city.title_ru
    end

    def find_city(attributes)
      conditions = []
      params = {}

      LOCALES.each do |locale|
        city_name = attributes[:"city_#{locale}"]
        next if city_name.blank?

        conditions << "title_#{locale} ILIKE :title_#{locale}"
        params[:"title_#{locale}"] = city_name
      end

      return nil if conditions.empty?

      City.where(region_id: attributes[:region_id])
          .where(conditions.join(' OR '), params)
          .first
    end

    def add_property_type(attributes, property_types: nil)
      property_type = find_property_type(property_types, attributes, LOCALES)
      attributes[:property_type_id] =
        if property_type.present?
          property_type.id
        else
          ::PropertyType::OTHER
        end
    end

    def property_types_preload
      @property_types_preload ||= ::PropertyType
                                    .select(:id, :title_ru, :title_en)
                                    .to_a
    end

    def add_agency(attributes)
      attributes[:agency_id] = @agency.id
    end

    def add_external_link(link, attributes)
      attributes[:external_link] = link
    end

    def pictures(property, attributes)
      if attributes.has_key?(:pictures)
        attributes[:pictures_attributes] = check_pictures(attributes[:pictures], pictures: property.pictures)
      end
    end

    def noncommercial_property_attribute(property, attributes)
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

    def save!(entity, attributes)
      permitted_attrs = permitted_params(attributes)

      # Разделяем атрибуты и изображения
      pictures_attrs = permitted_attrs.delete(:pictures_attributes)

      # Сохраняем основную сущность
      entity.assign_attributes(permitted_attrs)

      if entity.save
        # Если есть изображения, пробуем их добавить одно за другим
        if pictures_attrs.present?
          pictures_attrs.each do |pic_data|
            Picture.create(
              imageable: entity,
              description: pic_data[:description],
              remote_pic_url: pic_data[:remote_pic_url]
            )
          end
        end

        entity
      else
        raise entity&.errors&.messages&.to_json
      end
    end

end
