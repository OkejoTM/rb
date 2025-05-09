module Bitrix
  module Crm
    module Lead
      # https://dev.1c-bitrix.ru/rest_help/crm/leads/crm_lead_update.php
      class Update < Bitrix::Base
        class << self
          def call(id, fields, params)
            response = self.new.post(
              id: id,
              fields: fields,
              params: params
            )

            if response.success?
              true
            else
              raise Bitrix::Errors::Action.new(action: self.class, response: response)
            end
          end
        end
      end
    end
  end
end
