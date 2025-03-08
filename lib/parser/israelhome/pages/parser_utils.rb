module Parser::Israelhome::Pages::ParserUtils

  def load_locale(agent, locale, url) #copypaste
    return unless URI.decode(url).valid_encoding?  # боремся с кривыми символами в урле

    agent.reset # resets language

    parsed = URI.parse(url)
    request_uri_without_locale = parsed.request_uri.gsub(/\/(rus|eng|fra)/, '')
    localized_url = "http://#{parsed.host}/#{locale}#{request_uri_without_locale}"
    agent.load_page(localized_url)
  end

  def load_about(agent, locale)
    load_locale(agent, locale, 'http://israelhome.ru/rus/about_us.htm')
  end

  def load_contacts(agent, locale)
    load_locale(agent, locale, 'http://israelhome.ru/rus/contacts.htm')
  end
end
