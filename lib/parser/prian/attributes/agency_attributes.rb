class Parser::Prian::Attributes::AgencyAttributes < Parser::BaseAttributes

  # локали, которые поддерживает сайт Prian.ru
  def locales
    %i[ru en]
  end

  def anchor_locales
    {
      ru: {
        website: 'Сайт компании:'
      },
      en: {
        website: 'Website:'
      }
    }
  end

  def name
    take_last_element_text('h1') || ''
  end

  def about
    take_last_element_text('.pr-b-company-about > p') || ''
  end

  def website
    take_last_element('.company_go_link')&.attribute('href')&.value
  end

  def prian_link
    response.uri.to_s
  end

  def active_properties_count
    take_last_element_text('#company-objects > span')&.gsub(/[()]/, '')
  end

  def logo
    logo_src = ''
    img_item = take_last_element('img.logo')
    logo_src = img_item['src'] if img_item.present?

    if img_item.blank?
      src = take_last_element('.logotype')
      logo_src = src['style'].match(/(?<=url\().*(?=\))/) if src.present?
    end

    Parser::ParserUtils.wrap_url(logo_src) if logo_src.present?
  end

  def other_contacts
    other_contacts_block = response.css('.pr-b-contact .contact-item .item').first
    return [] if other_contacts_block.blank?

    other_contacts_block
      .children
      .select { |e| e.name == 'div' || e.name == 'p' }
      .slice_before { |elem| elem.name == 'div' }
      .map do |contacts|
        {
          title: contacts.first.text,
          content: contacts[1..-1].map { |elem| Parser::ParserUtils.delete_trailing_spaces(elem.inner_html) }
        }
      end
      .delete_if { |i| locales.any? { |locale| i[:title] == get_translation(locale, :website) } }
  end

  def contacts
    other_contacts.map do |c|
      {
        value: c[:content].first,
        contact_type: c[:title] # "Эл. адрес" не совпадет с Email
      }
    end
  end

  def contact_people
    contact_people_block = response.css('.pr-b-contact .contact-item .item > dl')
    return [] if contact_people_block.blank?

    contact_people_block.map do |contact_block|
      face = { img: '', name: '', role: '', contacts: {} }

      photo = contact_block.css('dt img').last
      face[:img] = Parser::ParserUtils.wrap_url(photo['src']) if photo.present?

      contact_info = contact_block.css('dd')
      face[:role] = Parser::ParserUtils.delete_trailing_spaces(contact_info.css('.name > span').last&.text) || ''
      face[:name] = Parser::ParserUtils.delete_trailing_spaces(contact_info.css('.name').last&.text&.gsub(face[:role], '')) || ''

      contact_info.css('a').each do |contact|
        type = contact['href'].split(':').first # mailto, tel, skype
        next if type.blank?
        face[:contacts][type] = contact.text.strip
      end

      face
    end
  end

  def messengers
    messengers_block = response.css('.pr-b-contact .contact-item .item')[2]
    return [] if messengers_block.blank?

    messengers_block
      .children
      .select { |e| e.name == 'div' || e.name == 'p' }
      .slice_before { |elem| elem.name == 'div' } # [[div, p, p, p]...]
      .map do |contacts|
        {
          title: contacts.first.text, # убрать title
          content: contacts[1..-1].map do |a|
            {
              type: a.css('i.svg-icon').map { |n| n['title'] },
              phone: Parser::ParserUtils.delete_trailing_spaces(a.css('a').first&.content)
            }
          end
        }
      end
  end

  def is_active
    take_last_element('.company-page__not-found').blank?
  end
end
