module Bitrix
  module Errors
    class BitrixActionError < StandardError
      extend Messegable

      define_message :exception_msg, "Action %s failed with code %s, body: %s"

      def initialize(action:, response:)
        super(exception_msg(action, response.code, response.body))
      end
    end
  end
end
