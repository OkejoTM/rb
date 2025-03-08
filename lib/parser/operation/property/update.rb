class Parser::Operation::Property::Update < Parser::Operation::BaseUpdate
  include Parser::Operation::Property::Base

  define_message :find_existing_failure_msg, 'Property not found'

  step :find_existing
  map :update_pictures
  map :update_commercial_property_attribute
  map :update_noncommercial_property_attribute
  map :update_property_tags
  step :save

  class << self
    def preload(property_where_cond:)
      existed_properties = Property
        .includes(:country,
                  :region,
                  :city,
                  :agency,
                  :property_type,
                  :commercial_property_attribute,
                  :noncommercial_property_attribute,
                  :pictures,
                  :property_tags)
        .where(*property_where_cond)

      existed_property_tags = PropertyTag
        .includes(:property_tag_aliases)
        .to_a

      Parser::Operation::Property::Update
        .new
        .with_step_args(
          find_existing: [relation: existed_properties],
          update_property_tags: [property_tags: existed_property_tags]
        )
    end
  end

  def existing_record_condition(property, attributes)
    property.external_link == attributes[:external_link]
  end

  def update_pictures(entity:, attributes:)
    if attributes.has_key?(:pictures)
      attributes[:pictures_attributes] = check_pictures(attributes[:pictures], pictures: entity.pictures)
    end

    { property: entity, attributes: attributes }
  end

  def update_commercial_property_attribute(property:, attributes:)
    has_property_attrs = attributes.has_key?(:rental_yield_per_year) && attributes.has_key?(:rental_yield_per_year_unit)

    if has_property_attrs
      attributes[:commercial_property_attribute_attributes] = check_commercial_property_attribute(
        property.commercial_property_attribute,
        attributes
      )
    end

    { property: property, attributes: attributes }
  end

  def check_commercial_property_attribute(commercial, property_attrs)
    commercial_attrs = commercial_property_attribute_hash(property_attrs)

    commercial_attrs[:id] = commercial.id if commercial.present?

    commercial_attrs
  end

  def update_noncommercial_property_attribute(property:, attributes:)
    has_property_attrs = attributes.keys.any? do |key|
      key.in?(%i[level level_count property_id bathroom_count bedroom_count])
    end

    if has_property_attrs
      attributes[:noncommercial_property_attribute_attributes] = check_noncomercial_property_attribute(
        property.noncommercial_property_attribute,
        attributes
      )
    end

    { property: property, attributes: attributes }
  end

  def check_noncomercial_property_attribute(noncommercial, property_attrs)
    noncommercial_attrs = noncomercial_property_hash(property_attrs)

    noncommercial_attrs[:id] = noncommercial.id if noncommercial.present?

    noncommercial_attrs
  end

  def update_property_tags(attributes, property_tags:)
    property = attributes[:property]
    attributes = attributes[:attributes]

    if attributes.has_key?(:property_tags)
      attributes.merge!(check_property_tags(
        property.property_tags,
        attributes[:property_tags],
        property_tags
      ))
    end

    { entity: property, attributes: attributes }
  end
end
