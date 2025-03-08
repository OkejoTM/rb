class Parser::Israelhome::Attributes::AgencyAttributes < Parser::BaseAttributes

  # http://israelhome.ru/rus/about_us.htm
  # http://israelhome.ru/eng/about_us.htm
  def about
    paragraphs = take_last_element('span.description').css('p')
    about_text = paragraphs[1..-1].map(&:text).join

    Parser::ParserUtils.delete_trailing_spaces(about_text)
  end

  def name
    'israelhome'
  end

  # http://israelhome.ru/
  def website
    'http://israelhome.ru/'
  end

  def logo
    'http://israelhome.ru/pictures/logo_general.png'
  end

  def is_active
    true
  end

  # http://israelhome.ru/rus/contacts.htm
  def contacts_ru
    contacts = []
    contact_block = take_last_element('span.description')
    return if contact_block.blank?
    text_blocks = take_last_element('span.description').children.reject(&:text?)

    text_blocks.each.with_index do |el, i|
      next_el = text_blocks[i + 1]&.text

      current_title = Parser::ParserUtils.delete_trailing_spaces(el.text)
      next_el = Parser::ParserUtils.delete_trailing_spaces(next_el)

      next if next_el.blank? || current_title.blank?

      if current_title == 'В Москве:'
        phone = next_el
                  .split(',')
                  .map do |phone|
                    {
                      value: phone,
                      contact_type: 'Телефон'
                    }
                  end
        contacts.concat(phone)
      elsif %w[Skype E-mail Факс].any? { |type| type.in?(current_title) }

        contact_type = current_title.gsub(':', '')

        contacts.push(value: next_el,
                      contact_type: contact_type)
      end

    end

    contacts
  end

  # http://israelhome.ru/rus/contacts.htm
  def contacts_en
    contact_block = response.css('span.description ul li')
    return if contact_block.blank?

    contact_block.map do |el|
      title = take_last_element_text('strong', resp: el)
      contact_type = title.gsub(':', '')

      if contact_type == 'Contact phone'
        contact_type = 'Phone'
      end

      value = take_last_element_text('span', resp: el)

      {
        value: value,
        contact_type: contact_type
      }
    end
  end
end
