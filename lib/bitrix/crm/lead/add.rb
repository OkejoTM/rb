module Bitrix
  module Crm
    module Lead
      # https://dev.1c-bitrix.ru/rest_help/crm/leads/crm_lead_add.php
      class Add < Bitrix::Base
        class << self

          # Создает Лид в Битриксе и возвращает его ID
          # За параметрами см. доки и crm.lead.fields
          # @param [Hash] fields параметры Лида
          # @param [Hash] params доп. параметры Лида
          # @return [Integer]
          def call(fields:, params:)
            response = self.new.post(
              fields: fields,
              params: params
            )

            if response.kind_of?(Net::HTTPSuccess)
              response_hash = JSON.parse(response.body)
              response_hash['result'].to_i
            else
              raise Bitrix::Errors::Action.new(action: self.class, response: response)
            end
          end
        end
      end
    end
  end
end
