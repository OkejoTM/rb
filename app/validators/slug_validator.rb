class SlugValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.blank?
      record.errors[attribute] << (options[:message] || "должно быть указано")
    end

    unless value =~ /\A[a-z0-9_\-]+\z/
      record.errors[attribute] << (options[:message] || 'В url могут быть только латинские символы в нижнем регистре, цифры и символы "_", "-"')
    end
  end
end
