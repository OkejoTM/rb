class AgencyBid::Presenter < BaseBidPresenter

  def to_bitrix_lead
    {
      **base_bitrix_hash,
      source_description: I18n.t('agency_bids.show', locale: :ru),
      status_id: 'IN_PROCESS', # id начального статуса заявки агентств в Битриксе
      title: "#{agency_name}: #{country_name}",
      phone: [{
        value_type: 'WORK',
        value: phone
      }],
      email: [{
        value_type: 'WORK',
        value: email
      }]
    }.tap do |h|
      if website.present?
        h[:website] = [{
          value_type: 'WORK',
          value: website
        }]
      end
    end
  end
end
