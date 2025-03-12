class AgencyBidValidator < BaseValidator
  def validate(record)
    %i[name phone email agency_name message].each do |field_name|
      blank_field_validation(record, field_name)
    end

    email_validation(record, :email)

    phone_validation(record, :phone)
  end
end
