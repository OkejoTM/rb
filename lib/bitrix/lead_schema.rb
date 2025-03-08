class Bitrix::LeadSchema
  class << self
    def call(data)
      schema = Dry::Schema.Params do
        required(:title).filled(:string)
        required(:status_id).filled(:string) # NEW(for clients), IN_PROCESS(for agencies)

        optional(:name).filled(:string)
        optional(:source_id).filled(:string) # WEB
        optional(:source_description).filled(:string)
        optional(:comments).filled(:string)
        optional(:currency_id).filled(:string)
        optional(:opportunity).filled(:integer) # price
        optional(:opened).filled(:string)

        optional(:phone).array(:hash) do
          required(:value).filled(:string)
          required(:value_type).filled(:string) # WORK
        end

        optional(:web).array(:hash) do
          required(:value).filled(:string)
          required(:value_type).filled(:string) # WORK
        end

        optional(:email).array(:hash) do
          required(:value).filled(:string)
          required(:value_type).filled(:string) # WORK
        end
      end

      result = schema.call(data)

      if result.success?
        upcase_recursive(result.to_h)
      else
        raise Bitrix::Errors::BitrixValidationError.new(errors: result.errors.to_h)
      end
    end

    def upcase_recursive(hash)
      hash.transform_keys(&:upcase)
          .transform_values do |value|
            if value.is_a?(Hash)
              upcase_recursive(value)
            elsif value.is_a?(Array)
              value.map { |ar_val| upcase_recursive(ar_val) }
            else
              value
            end
          end
    end
  end
end
