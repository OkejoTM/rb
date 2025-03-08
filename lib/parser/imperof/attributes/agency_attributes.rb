class Parser::Imperof::Attributes::AgencyAttributes < Parser::BaseAttributes
  def name
    'imperoforte'
  end

  def about
    # https://imperof.com/ru/our-company/
    take_last_element_text('.panel-widget-style.panel-widget-style-for-1137-0-1-1 div div')
  end

  def website
    Parser::ParserUtils.wrap_url("//#{response.uri.host}")
  end

  def logo
    # https://imperof.com/*
    img_el = take_last_element('#logo img')
    return if img_el.blank?
    img_el['src']
  end

  def other_contacts_ru
    # https://imperof.com/ru/contact/
    ru_contact = take_last_element('.contact-details.clearfix ul.contacts-list') # Берет информацию из блока "В России"

    ru_contact.css('li').map do |li|
      title_with_content = li.text
      title, content = title_with_content
                         .split(':')
                         .map { |text| Parser::ParserUtils.delete_trailing_spaces(text) }
      {
        title: title,
        content: [content]
      }
    end
  end

  def contacts_ru
    other_contacts_ru.map do |c|
      {
          value: c[:content].first,
          contact_type: c[:title] # "Эл. адрес" не совпадет с Email
      }
    end
  end

  def is_active
    true
  end
end
