module Admin::RealEstateParserLogsHelper
  def statuses
    t('real_estate_parser_logs.statuses').invert
  end

  def status(status)
    t("real_estate_parser_logs.statuses.#{status}")
  end
end
