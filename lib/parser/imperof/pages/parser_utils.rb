module Parser::Imperof::Pages::ParserUtils
  extend self

  def load_locale(agent, locale, url)
    return unless URI.decode(url).valid_encoding?  # боремся с кривыми символами в урле

    parsed = URI.parse(url)
    request_uri_without_locale = parsed.request_uri.gsub(/\/(ru|en|it)/, '')
    localized_url = "https://#{parsed.host}/#{locale}#{request_uri_without_locale}"
    agent.load_page(localized_url)
  end

  def load_about(agent, locale)
    load_locale(agent, locale, 'https://imperof.com/our-company/')
  end

  def load_contacts(agent, locale)
    load_locale(agent, locale, 'https://imperof.com/contact/')
  end

  def load_property_search(agent, locale)
    load_locale(agent, locale, 'https://imperof.com/property-search/')
  end

  def ru?(page)
    '/ru/'.in?(page.uri.to_s)
  end

  def en?(page)
    !(ru?(page) || it?(page))
  end

  def it?(page)
    '/it/'.in?(page.uri.to_s)
  end

  def coordinate_regex(coordinate_type)
    /"#{coordinate_type}"\s*:\s*"(?<coordinate>\d+\.\d+)/
  end
end
