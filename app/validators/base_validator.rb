class BaseValidator < ActiveModel::Validator
  protected
    def phone_validation(record, field)
      return if record[field].present? && record[field].size >= 6 || record[field].blank?

      record.errors[field] << I18n.t('errors.incorrectly_phone')
    end

    def email_validation(record, field)
      return unless record[field].present? && !record[field] =~ User::EMAIL_REGEX

      record.errors[field] << I18n.t('errors.incorrectly_email')
    end

    def blank_field_validation(record, field)
      return if record[field].present?

      record.errors[field] << I18n.t('errors.must_be_specified')
    end
end
