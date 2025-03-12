class UniqFieldValidator < ActiveModel::Validator
  def validate(record)
    field = options[:field]
    included_classes = options[:included_classes]

    return if record.send(field).blank?

    included_classes.each do |klass|
      scope = klass.where(field => record.send(field))
      if record.persisted? && klass == record.class
        scope = scope.where.not(id: record.id)
      end
      if scope.any?
        record.errors.add field, 'is already taken'
        break
      end
    end
  end
end
