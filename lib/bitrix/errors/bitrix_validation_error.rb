module Bitrix
  module Errors
    class BitrixValidationError < StandardError
      extend Messegable

      define_message :exception_msg, "Bitrix validation failed with errors: %s"

      def initialize(errors:)
        super(exception_msg(errors))
      end
    end
  end
end
