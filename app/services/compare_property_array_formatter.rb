class ComparePropertyArrayFormatter
  class << self
    # Merge the given compare_array into a hash where each key represents a tag
    # and the value is an array of all the values associated with that tag.
    #
    # @param compare_array [Array<Hash>] the array of hashes to be merged
    # @return [Hash, nil] the merged hash if compare_array is not empty or nil
    def format_array(compare_array)
      return compare_array if compare_array.blank?

      max_index = 0
      res = Hash.new { |hash, key| hash[key] = [] }.tap do |result|
        compare_array.each_with_index do |tag_hash, index|
          max_index = index if index > max_index
          tag_hash.each { |key, value| result[key][index] = value }
        end
      end

      res.each_value do |value|
        value[max_index] = nil if value.length < max_index + 1
      end

      res
    end
  end
end
