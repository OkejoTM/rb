class Parsers::Vartur::Operations::Property::Upsert
  include ActiveModel::Validations
  include Parsers::Operation::Property::Base

  attr_reader :entity

  def call(property_url, attributes)
    @entity = find_existing(property_url)

    if @entity.new_record?
      add_country(attributes, countries: countries_preload)
      add_region(attributes, regions: regions_preload)
      add_city(attributes, cities: cities_preload)
      add_property_type(attributes, property_types: property_types_preload)
      add_agency(attributes, existed_agency: existed_agency)
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

    def locales
      %i[ru en]
    end

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

    def add_country(attributes, countries: nil)
      country = find_country(countries, attributes, locales)
      attributes[:country_id] = country.id
    end

    def countries_preload
      @countries_preload ||= Country
                               .select(:id, :title_ru, :title_en, :name)
                               .to_a
    end

    def add_region(attributes, regions: nil)
      attributes[:region_en] = attributes[:city_en] if attributes[:region_en].blank?
      region = find_region(regions, attributes, locales)
      if region.blank?
        region = find_region_by_alternate_name(attributes)
      end

      return attributes if region.blank?

      attributes[:region_id] = region.id
      attributes[:region_name_en] = region.title_en
      attributes[:region_name_ru] = region.title_ru
    end

    def regions_preload
      @regions_preload = Region
                           .select(:id, :title_ru, :title_en, :name, :country_id)
                           .to_a
    end

    def add_city(attributes, cities: nil)
      city = find_city(cities, attributes, locales)
      if city.blank?
        city = find_city_by_alternate_name(attributes)
      end

      return attributes if city.blank?

      attributes[:city_id] = city.id
      attributes[:city_name_en] = city.title_en
      attributes[:city_name_ru] = city.title_ru
    end

    def cities_preload
      @cities_preload ||= City
                            .select(:id, :title_ru, :title_en, :name)
                            .to_a
    end

    def add_property_type(attributes, property_types: nil)
      property_type = find_property(property_types, attributes, locales)
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

    def add_agency(attributes, existed_agency:)
      attributes[:agency_id] = existed_agency.id
    end

    def existed_agency
      @existed_agency ||= ::Agency
                              .select(:id, :website, :parse_source)
                              .where('website=:link', link: Parsers::ParserUtils.wrap_url(Parsers::Vartur::Schema::AGENCY_URL))
                              .first
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

    def save(entity, attributes)
      permitted_attrs = permitted_params(attributes)

      # Разделяем атрибуты и изображения
      pictures_attrs = permitted_attrs.delete(:pictures_attributes)

      # Сохраняем основную сущность
      entity.assign_attributes(permitted_attrs)

      if entity.save
        # Если есть изображения, пробуем их добавить одно за другим
        if pictures_attrs.present?
          pictures_attrs.each do |pic_data|
            begin
              Picture.create(
                imageable: entity,
                description: pic_data[:description],
                remote_pic_url: pic_data[:remote_pic_url]
              )
            end
          end
        end

        entity
      else
        raise entity&.errors&.messages&.to_json
      end
    end

end
