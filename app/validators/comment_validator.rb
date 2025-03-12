class CommentValidator < BaseValidator
  def validate(record)
    %i[message item_type item_id created_by_id].each do |field_name|
      blank_field_validation(record, field_name)
    end
  end
end
