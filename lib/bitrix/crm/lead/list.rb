module Bitrix
  module Crm
    module Lead
      # https://dev.1c-bitrix.ru/rest_help/crm/leads/crm_lead_list.php
      class List < Bitrix::Base
        class << self
          def call
            response = self.new.get

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
