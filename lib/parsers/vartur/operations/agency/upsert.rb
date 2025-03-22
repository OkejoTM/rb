class Parsers::Vartur::Operations::Agency::Upsert
  include Parsers::Operation::Agency::Base
  include ActiveModel::Validations

  attr_reader :entity

  def call(agency_url, attributes)
    @entity = find_agency(agency_url)

    if @entity.new_record?
      # Создание нового агентства
      create_result = create_agency(attributes)
      @entity = create_result if create_result
    else
      # Обновление существующего агентства
      update_result = update_agency(@entity, attributes)
      @entity = update_result if update_result
    end

    true
  rescue => e
    errors.add(:base, message: e.message)
    false
  end

  private

    def find_agency(agency_url)
      entity =
        ::Agency.includes(:logo,
                          :contacts,
                          :agency_other_contacts,
                          :contact_people,
                          :messengers,
                          messengers: [:messenger_type],
                          contact_people: [:contacts])
                .where(website: Parsers::ParserUtils.wrap_url(agency_url))
                .first

      entity.presence || ::Agency.new
    end

    def create_agency(attributes)
      create_op = Parser::Operation::Agency::Create.new
      result = create_op.call(attributes)
      result.value!
    end

    def update_agency(entity, attributes)
      agency_where_cond = ["website = ?", entity.website]
      update_op = Parser::Operation::Agency::Update.preload(
        agency_where_cond: agency_where_cond
      )
      result = update_op.call(attributes)
      result.value!
    end
end
