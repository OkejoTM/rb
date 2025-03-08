class Parser::Operation::Agency::Create < Parser::Operation::BaseCreate
  include Parser::Operation::Agency::Base

  # TODO: think about one interface between Operation and Parser, that maps attribute_map with locales, etc
  map :add_contact_people
  map :add_other_contacts
  map :add_contacts
  map :add_messengers
  map :add_logo
  map :add_slug
  map :add_seo
  step :save

  def add_contact_people(attributes)
    handle_monad(
      Parser::Operation::ContactPerson::AttributesForCreate,
      %i[attributes],
      attributes: attributes,
      agency: nil,
    )
  end

  def add_other_contacts(attributes:)
    handle_monad(
      Parser::Operation::OtherContact::AttributesForCreate,
      %i[attributes],
      attributes: attributes,
      agency: nil,
    )
  end

  def add_contacts(attributes:)
    handle_monad(
      Parser::Operation::Contact::AttributesForCreate,
      %i[attributes],
      attributes: attributes,
      agency: nil,
    )
  end

  def add_messengers(attributes:)
    handle_monad(
      Parser::Operation::Messenger::AttributesForCreate,
      %i[attributes],
      attributes: attributes,
      agency: nil,
    )
  end

  def add_logo(attributes:)
    logo = check_logo(attributes[:logo])
    if logo.present?
      attributes[:logo_attributes] = logo
    end

    { attributes: attributes }
  end

  def add_slug(attributes:)
    attributes[:slug] = attributes[:name_en].parameterize

    { attributes: attributes }
  end

  def add_seo(attributes:)
    attributes[:seo_agency_page] = SeoAgencyPage.new_default_agency_page

    { attributes: attributes }
  end
end
