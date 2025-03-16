class Parsers::Vartur::Attributes::AgencyAttributes < Parser::BaseAttributes
  def name
    'vartur'
  end

  def about_en
    sections = []

    ancestors_section = response.css('.title.mission h4:contains("ANCESTORS OF ROOTED VARLI FAMILY")').first
    if ancestors_section
      sections << ancestors_section.parent.parent.css('.desc p').map(&:text).join(' ').strip
    end

    # The Father section
    father_section = response.css('.title.mission h4:contains("THE FATHER ŞEREF VARLI")').first
    if father_section
      sections << father_section.parent.parent.css('.desc p').map(&:text).join(' ').strip
    end

    # Present family section
    present_section = response.css('h2.fw-bold:contains("VARLI FAMILY NOW")').first
    if present_section
      # Doğan section
      dogan_section = response.css('.title.mission h4:contains("DOĞAN NADİ VARLI")').first
      if dogan_section
        dogan_text = dogan_section.parent.parent.css('p').map(&:text).join(' ').strip
        sections << dogan_text
      end

      # Şerif section
      serif_section = response.css('.title.mission h4:contains("ŞERİF NADİ VARLI")').first
      if serif_section
        serif_text = serif_section.parent.parent.css('p').map(&:text).join(' ').strip
        sections << serif_text
      end
    end

    sections.compact_blank.join("\n\n").strip
  end

  def about_ru
    return if response.blank?

    content_div = response.css('div.mt-3.text-gray-700').first
    return if content_div.blank?

    # Собираем все параграфы, кроме тех что содержат только изображения
    paragraphs = content_div.css('p').reject do |p|
      p['dir'] == 'ltr' || # Пропускаем параграфы с изображениями
        p.text.strip.blank? # Пропускаем пустые параграфы
    end

    # Объединяем текст всех параграфов
    paragraphs.map(&:text).join("\n\n").strip
  end

  def website
    Parser::ParserUtils.wrap_url("//#{response.uri.host}")
  end

  def logo
    img_el = take_last_element('div.flex > a.flex > img')
    return if img_el.blank?
    website + img_el['src']
  end

  def other_contacts_en
    contacts = []
    return contacts if response.blank?

    # Find the footer section
    footer = response.css('footer')
    return contacts if footer.blank?

    phone_type = 'Phone'
    email_type = 'E-mail'

    phone_link = footer.css('ul li a[href^="tel:"]').first
    if phone_link && phone_type
      phone = phone_link['href'].gsub('tel:', '').strip
      contacts << {
        title: phone_type,
        content: [phone]
      }
    end

    # Extract email from footer
    email_link = footer.css('ul li a[href^="mailto:"]').first
    if email_link && email_type
      email = email_link['href'].gsub('mailto:', '').strip
      contacts << {
        title: email_type,
        content: [email]
      }
    end

    contacts
  end

  def other_contacts_ru
    []
  end

  def contacts_en
    other_contacts_en.map do |c|
      {
        value: c[:content].first,
        contact_type: c[:title]
      }
    end
  end

  def contacts_ru
    []
  end

  def is_active
    true
  end
end
