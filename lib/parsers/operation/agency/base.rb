module Parsers::Operation::Agency::Base

  # Проверяет является ли ссылка с изображением лого рабочей и возвращает хэш для создания, если это так
  # @param [String] logo_url
  # @return [Hash]
  def check_logo(logo_url)
    return {} unless Parser::ParserUtils.img_exist?(logo_url)
    { remote_pic_url: logo_url }
  end

  protected
    def permitted_params(params)
      acceptable_params = Agency.attribute_names.deep_dup.map(&:to_sym).push(
        :contact_people_attributes,
        :contacts_attributes,
        :messengers_attributes,
        :agency_other_contacts_attributes,
        :logo_attributes,
        :seo_agency_page,
      )

      params.slice(*acceptable_params)
    end
end
