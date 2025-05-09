require 'rails/generators'

class ParserGeneratorGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  def create_schema
    template "properties_schema_template.rb",
             "#{parser_path}/schemas/properties_schema.rb"
  end

  def create_attributes
    template 'property_attributes_template.rb',
              "#{parser_path}/attributes/property_attributes.rb"
  end

  def create_property_parser
    template 'property_parser_template.rb',
              "#{parser_path}/pages/property_parser.rb"
  end

  def create_url_grabber
    template 'url_grabber_template.rb',
              "#{parser_path}/pages/url_grabber.rb"
  end

  private

    def snake_case_name
      name.underscore
    end

    def parser_path
      "lib/parser/#{snake_case_name}"
    end
end
