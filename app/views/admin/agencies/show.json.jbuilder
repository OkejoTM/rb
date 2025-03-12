json.agency do
  json.extract! agency,
                  :id,
                  :name_ru,
                  :name_en,
                  :about_ru,
                  :about_en,
                  :website,
                  :org_name_ru,
                  :org_name_en,
                  :is_active,
                  :show_on_website,
                  :slug,
                  :has_contract

  json.logo_attributes agency.logo

  json.contact_people_attributes agency.contact_people do |contact_person|
    json.extract!(contact_person, :id, :role_ru, :role_en, :name_ru, :name_en, :agency_id)
    json.avatar_attributes contact_person.avatar

    json.contacts_attributes contact_person.contacts do |contact|
      json.extract!(contact, :id, :value, :contactable_id, :contactable_type, :contact_type_id)
    end
  end

  json.contacts_attributes agency.contacts,
                           :id, :value, :contactable_id, :contactable_type, :contact_type_id

  json.agency_other_contacts_attributes agency.agency_other_contacts,
                                        :id, :title_ru, :title_en, :content_ru, :content_en, :agency_id

  json.messengers_attributes agency.messengers,
                             :id, :phone, :messenger_type_id, :agency_id

  if agency.seo_agency_page.present?
    json.seo_agency_page_attributes agency.seo_agency_page, :id, :h1_ru, :h1_en,
                                                          :title_ru, :title_en,
                                                          :description_ru, :description_en,
                                                          :meta_description_ru, :meta_description_en,
                                                          :agency_id, :is_active, :default_page_id
  end
end

json.html_params do
  json.messenger_types MessengerType.select(:id, :title)
  json.contact_types ContactType.select(:id, :title_ru)
  json.notice notice
  json.edit_path edit_path if defined?(edit_path) && edit_path.present?
end
