module Bitrix
  class Base

    class << self

      def token_owner_id
        Rails.application.credentials.dig(:bitrix, :token_owner_id)
      end

      def webhook_token
        Rails.application.credentials.dig(:bitrix, :webhook_token)
      end

      def bitrix_domain
        Rails.application.credentials.dig(:bitrix, :bitrix_domain)
      end

      def rest_endpoint
        "https://#{Bitrix::Base.bitrix_domain}.bitrix24.ru/rest/#{Bitrix::Base.token_owner_id}/#{Bitrix::Base.webhook_token}"
      end
    end

    def api_action_name
      class_name = self.class.to_s
      class_name
          .gsub!('Bitrix::', '')
          .underscore
          .gsub!('/', '.')
    end

    def url
      "#{Bitrix::Base.rest_endpoint}/#{api_action_name}"
    end

    def uri
      URI(url)
    end

    def post(data)
      payload = data.to_json
      Net::HTTP.post(
        uri,
        payload,
        'Content-Type' => 'application/json'
      )
    end

    def get
      Net::HTTP.get(uri)
    end
  end
end
