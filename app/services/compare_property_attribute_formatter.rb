class ComparePropertyAttributeFormatter
  class << self
    # Generates a hash representation of a property object.
    #
    # @param property [Property] The property object to be converted.
    # @return [Hash] The hash representation of the property object.
    def create_property_hash(property)
      return nil if property.blank?
      res = { property: property }

      main_features = property.formatted_fields(fields: property.fields_for_main_features)
      details = property.formatted_fields(fields: property.fields_for_details)
      features = property.property_tags.moderated.find_each do |memo, tag|
        memo[tag.title.parameterize.underscore.to_sym] = true
      end || {}

      res.merge(main_features, details, features)
    end
  end
end
