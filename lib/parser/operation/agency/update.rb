class Parser::Operation::Agency::Update < Parser::Operation::BaseUpdate
  include Parser::Operation::Agency::Base

  define_message :find_existing_failure_msg, 'Агентство не найдено'

  step :find_existing
  map :update_contact_people
  map :update_other_contacts
  map :update_contacts
  map :update_messengers
  map :update_logo
  step :save

  class << self
    def preload(agency_where_cond:)
      existed_agencies = Agency
        .includes(:logo,
                  :contacts,
                  :agency_other_contacts,
                  :contact_people,
                  :messengers,
                  messengers: [:messenger_type],
                  contact_people: [:contacts])
        .where(*agency_where_cond)

      Parser::Operation::Agency::Update
        .new
        .with_step_args(find_existing: [relation: existed_agencies])
    end
  end

  def existing_record_condition(agency, attributes)
    agency.prian_link == attributes[:prian_link]
  end

  def update_contact_people(entity:, attributes:)
    handle_monad(
      Parser::Operation::ContactPerson::AttributesForUpdate,
      %i[agency attributes],
      agency: entity,
      attributes: attributes
    )
  end

  def update_other_contacts(agency:, attributes:)
    handle_monad(
      Parser::Operation::OtherContact::AttributesForUpdate,
      %i[agency attributes],
      agency: agency,
      attributes: attributes
    )
  end

  def update_contacts(agency:, attributes:)
    handle_monad(
      Parser::Operation::Contact::AttributesForUpdate,
      %i[agency attributes],
      agency: agency,
      attributes: attributes
    )
  end

  def update_messengers(agency:, attributes:)
    handle_monad(
      Parser::Operation::Messenger::AttributesForUpdate,
      %i[agency attributes],
      agency: agency,
      attributes: attributes
    )
  end

  def update_logo(agency:, attributes:)
    logo = check_logo(attributes[:logo])
    if logo.present?
      attributes[:logo_attributes] = logo
    end

    { entity: agency, attributes: attributes }
  end
end
