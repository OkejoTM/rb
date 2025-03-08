module Parser::Prian::Pages::ParserUtils
  extend self

  def calculate_next_step(page)
    element = page.css('.pagination-square__nav[aria-label="Next"]').last
    return if element.blank?

    next_link = element['href']
    return if next_link.blank?

    CGI.parse(URI.parse(next_link).query).fetch('next', []).first&.to_i
  end

  def load_locale(page, agent, locale)
    search_form = page.form_with(name: 'language_form')
    search_form['head_language'] = locale.to_s
    agent.agent.submit(search_form)
  end
end
