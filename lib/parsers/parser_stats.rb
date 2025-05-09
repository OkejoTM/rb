# lib/parsers/real_estate_parser_stats.rb
class Parsers::ParserStats
  attr_reader :created_properties_count, :updated_properties_count, :deleted_properties_count, :error_properties_count, :total_properties_count, :status

  def initialize
    @created_properties_count = 0
    @updated_properties_count = 0
    @deleted_properties_count = 0
    @error_properties_count = 0
    @total_properties_count = 0
    @status = 'in_progress'
    @changed = true
  end

  def increment_created_properties(count = 1)
    @created_properties_count += count
    @changed = true
  end

  def increment_updated_properties(count = 1)
    @updated_properties_count += count
    @changed = true
  end

  def increment_error_properties(count = 1)
    @error_properties_count += count
    @changed = true
  end

  def set_deleted_properties(count)
    @deleted_properties_count = count
    @changed = true
  end

  def set_total_properties(count)
    @total_properties_count = count
    @changed = true
  end

  def mark_error
    @status = 'unsuccess'
    @changed = true
  end

  def mark_success
    @status = 'success'
    @changed = true
  end

  def mark_partial_success
    @status = 'partial_success'
    @changed = true
  end

  def parsed_count
    @created_properties_count + @updated_properties_count + @error_properties_count
  end

  def not_in_database
    @total_properties_count - @created_properties_count - @updated_properties_count - @error_properties_count
  end

  def changed?
    @changed
  end

  def reset_changed
    @changed = false
  end

  def to_h
    {
      created_properties_count: @created_properties_count,
      updated_properties_count: @updated_properties_count,
      deleted_properties_count: @deleted_properties_count,
      error_properties_count: @error_properties_count,
      total_properties_count: @total_properties_count,
      status: @status
    }
  end
end
