class ClientFeedback::Presenter < BaseBidPresenter

  def to_bitrix_lead
    {
      **base_bitrix_hash,
      source_description: I18n.t('client_feedbacks.show', locale: :ru),
      status_id: 'NEW',
      title: "№ #{id} #{name} #{I18n.t('client_feedbacks.show', locale: :ru)}",
      phone: [{
        value_type: 'WORK',
        value: phone
      }]
    }
  end
end
