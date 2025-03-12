class ClientFeedbackValidator < BaseValidator
  def validate(record)
    %i[name phone message].each do |field_name|
      blank_field_validation(record, field_name)
    end

    phone_validation(record, :phone)
  end
end
