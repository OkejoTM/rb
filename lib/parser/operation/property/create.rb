class Parser::Operation::Property::Create < Parser::Operation::BaseCreate
  include Parser::Operation::Property::Base

  step :add_pictures
  map :add_country
  map :add_region
  map :add_city
  map :add_property_type
  map :add_commercial_property_attribute
  map :add_noncommercial_property_attribute
  map :add_property_tags
  map :add_agency
  step :save

  class << self
    def preload(agency_where_cond:)
      existed_agencies = Agency
        .select(:id, :prian_link, :website, :parse_source)
        .where(*agency_where_cond)
        .to_a

      countries_preload = Country
        .select(:id, :title_ru, :title_en, :name)
        .to_a

      regions_preload = Region
        .select(:id, :title_ru, :title_en, :name, :country_id)
        .to_a

      cities_preload = City
        .select(:id, :title_ru, :title_en, :name, :region_id)
        .to_a

      property_types_preload = PropertyType
        .select(:id, :title_ru, :title_en)
        .to_a

      property_tags_preload = PropertyTag
        .includes(:property_tag_aliases)
        .to_a

      Parser::Operation::Property::Create
        .new
        .with_step_args(
          add_agency: [existed_agencies: existed_agencies],
          add_country: [countries: countries_preload],
          add_region: [regions: regions_preload],
          add_city: [cities: cities_preload],
          add_property_type: [property_types: property_types_preload],
          add_property_tags: [property_tags: property_tags_preload],
        )
    end
  end

  def add_pictures(attributes)
    pictures = check_pictures(attributes[:pictures])

    if pictures.present?
      attributes[:pictures_attributes] = pictures
    else
      return Failure(no_pictures(attributes[:external_link]))
    end

    Success(attributes)
  end

  def add_country(attributes, countries: nil)
    country = find_country(countries, attributes, locales)

    attributes[:country_id] = country.id

    attributes
  end

  def add_region(attributes, regions: nil)
    region = find_region(regions, attributes, locales)

    return attributes if region.blank?

    attributes[:region_id] = region.id

    attributes
  end

  def add_city(attributes, cities: nil)
    city = find_city(cities, attributes, locales)

    return attributes if city.blank?

    attributes[:city_id] = city.id

    attributes
  end

  def add_property_type(attributes, property_types: nil)
    property_type = find_property(property_types, attributes, locales)

    attributes[:property_type_id] =
      if property_type.present?
        property_type.id
      else
        PropertyType::OTHER
      end

    { attributes: attributes }
  end

  def add_commercial_property_attribute(attributes:)
    attributes[:commercial_property_attribute_attributes] = commercial_property_attribute_hash(attributes)

    { attributes: attributes }
  end

  def add_noncommercial_property_attribute(attributes:)
    attributes[:noncommercial_property_attribute_attributes] = noncomercial_property_hash(attributes)

    attributes
  end

  def add_property_tags(attributes, property_tags:)

    if attributes.has_key?(:property_tags)
      attributes.merge!(check_property_tags(
        [],
        attributes[:property_tags],
        property_tags
      ))
    end

    attributes
  end

  def add_agency(attributes, existed_agencies:)
    # FIXUP: bad way to match
    agency = existed_agencies.find { |ag| attributes[:agency_link].in?([ag.prian_link, ag.website, ag.parse_source]) }
    attributes[:agency_id] = agency.id

    { attributes: attributes }
  end
end
