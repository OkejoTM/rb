module Constraints
  # Класс для проверки наличия сео-шаблона (используется в роутах)
  class SeoTemplateExistence

    # @param request [ActionDispatch::Request]
    # @return [Boolean] существует ли сео-шаблон
    def matches?(request)
      return false unless request.path_parameters[:template_slug].match(/[a-z0-9\-_].+/)
      # return false unless request.path_parameters[:country_url].match(/[a-z0-9\-_].+/)

      SeoTemplate.exists?(slug: request.path_parameters[:template_slug])
    end
  end
end
