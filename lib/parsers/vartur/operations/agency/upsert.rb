class Parsers::Vartur::Operations::Agency::Upsert
  include ActiveModel::Validations

  attr_reader :entity

  def call(agency_url, attributes)
    @entity = find_agency(agency_url, attributes)
    if @entity.new_record?
      add_slug(attributes)
      add_seo(attributes)
    end
    contacts(attributes)
    save(@entity, attributes)

    true
  rescue => e
    errors.add(:base, message: e.message)
    false
  end

  private

    def find_agency(agency_url, attributes)
      existed_agencies =
        ::Agency.includes(:logo,
                          :contacts,
                          :agency_other_contacts,
                          :contact_people,
                          :messengers,
                          messengers: [:messenger_type],
                          contact_people: [:contacts])
                .where(website: "https://#{agency_url}")

      entity = existed_agencies.find { |entity| existing_record_condition(entity, attributes) }

      entity.presence || ::Agency.new
    end

    def existing_record_condition(entity, attributes)
      entity.website == attributes[:website]
    end

    def add_slug(attributes)
      attributes[:slug] = attributes[:name_en].parameterize
    end

    def add_seo(attributes)
      attributes[:seo_agency_page] = ::SeoAgencyPage.new_default_agency_page
    end

    def contacts(attributes)
      attributes[:contacts_attributes] = attributes[:contacts_en]
    end

    def save(entity, attributes)
      permitted_attrs = permitted_params(attributes)
      entity.assign_attributes(permitted_attrs)

      if entity.save
        entity
      else
        raise entity&.errors&.messages&.to_json
      end
    end

    def permitted_params(params)
      acceptable_params = ::Agency.attribute_names.deep_dup.map(&:to_sym).push(
        :contacts_attributes,
        :agency_other_contacts_attributes,
        :logo_attributes,
        :seo_agency_page
      )

      params.slice(*acceptable_params)
    end
end
