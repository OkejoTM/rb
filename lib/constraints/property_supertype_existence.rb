module Constraints
  class PropertySupertypeExistence
    def matches?(request)
      PropertySupertype::SLUGS.values.include?(request.path_parameters[:property_supertype])
    end
  end
end
