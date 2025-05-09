module Constraints
  # Класс для проверки наличия сео-шаблона (используется в роутах)
  class GetParamsExistence

    # @param request [ActionDispatch::Request]
    # @return [Boolean] существует ли сео-шаблон
    def matches?(request)
      request.query_parameters.present?
    end
  end
end
