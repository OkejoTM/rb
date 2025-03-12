class BaseBidPresenter < BasicPresenter

  def contact_ways_message
    ways = contact_ways.map(&:way_type)
    ways =
      if ways.present?
        ways.join(', ')
      else
        I18n.t('common.not_filled', locale: :ru)
      end

    "#{I18n.t('contact_ways.preferred_ways', locale: :ru)}: #{ways}"
  end

  def country_name
    country&.title_ru || I18n.t('common.no_country', locale: :ru)
  end

  def bitrix_url
    "https://#{Bitrix::Base.bitrix_domain}.bitrix24.ru/crm/lead/details/#{bitrix_id}/"
  end

  private

    def base_bitrix_hash
      {
        source_id: 'WEB',
        name: name,
        comments: message.concat("\n", contact_ways_message),
        opened: 'Y',
      }
    end
end
