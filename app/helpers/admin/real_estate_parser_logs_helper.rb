module Admin::RealEstateParserLogsHelper
  def parser_logs_status(status)
    t("real_estate_parser_logs.statuses.#{status}")
  end

  def parser_log_status_with_color(status)
    color =
      case status
        when "success" then "green"
        when "unsuccess" then "red"
        when "partial_success" then "gold"
        else ""
      end

    content_tag(:span, parser_logs_status(status), style: "color: #{color};")
  end
end
