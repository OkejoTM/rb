class BidValidator < BaseValidator
  def validate(record)
    [:name, :email, :message, :phone, :property_id].each do |field_name|
      blank_field_validation(record, field_name)
    end

    unless record.phone.blank? || record.email =~ User::EMAIL_REGEX
      record.errors[:email] << I18n.t('errors.incorrectly_email')
    end

    phone_validation(record, :phone)
  end
end
