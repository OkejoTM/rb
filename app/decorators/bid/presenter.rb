class Bid::Presenter < BaseBidPresenter

  def to_bitrix_lead
    opportunity =
      if price_on_request
        0
      else
        sale_price
      end

    {
      **base_bitrix_hash,
      source_description: Rails.application.routes.url_helpers.property_url(property.id),
      status_id: 'NEW', # id начального статуса заявки обращений в Битриксе
      title: "№ #{id} #{name} #{country_name}",
      opportunity: opportunity,
      currency_id: sale_price_unit,
    }.tap do |h|
      if phone.present?
        h[:phone] = [{
          value_type: 'WORK',
          value: phone
        }]
      end

      if email.present?
        h[:email] = [{
          value_type: 'WORK',
          value: email
        }]
      end
    end
  end
end
