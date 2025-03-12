class BidSynchronizer
  def initialize(bid)
    @bid = bid
  end

  def call
    prepared_hash = @bid.present.to_bitrix_lead
    validated_hash = Bitrix::LeadSchema.call(prepared_hash)
    bitrix_id = Bitrix::Crm::Lead::Add.call(
      fields: validated_hash,
      params: {}
    )
    @bid.update_columns(bitrix_synced: :success, bitrix_id: bitrix_id)
  rescue Bitrix::Errors::BitrixActionError => e
    @bid.update_columns(bitrix_synced: :fail)
    raise e
  end
end
