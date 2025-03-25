class Parsers::Operation::Country::Search
  attr_reader :result

  def initialize(attributes, locales)
    @attributes = attributes
    @locales = locales
    @result = nil
  end

  def call
    @result = find_by_title(@attributes, @locales)
    !@result.nil?
  end

  private

    def find_by_title(attributes, locales)
      conditions = []
      params = {}

      locales.each do |locale|
        country_name = attributes[:"country_name_#{locale}"]
        next if country_name.blank?

        conditions << "title_#{locale} ILIKE :title_#{locale}"
        params[:"title_#{locale}"] = country_name
      end

      return nil if conditions.empty?

      Country.where(conditions.join(' OR '), params).first
    end
end
