module PropertiesHelper
  def listing_features(property)
    property.formatted_fields(fields: property.fields_for_tile, limit: 4)
      .then { |features| features_to_list(features, class: 'listing-features') }
      &.html_safe
  end

  def main_features(property)
    property.formatted_fields(fields: property.fields_for_main_features)
      .then { |features| features_to_list(features, class: 'property-main-features') }
      &.html_safe
  end

  def details(property)
    property.formatted_fields(fields: property.fields_for_details)
      .then { |features| features_to_list(features, class: 'property-features margin-top-0') }
      .then { |list| "<h3 class='desc-headline'>#{t(:details, scope: :common)}</h3>#{list}" if list.present? }
      &.html_safe
  end

  def features(property, **options)
    result = ''
    result << "<li>#{t(:studio, scope: :properties)}</li>" if property.studio?

    property.property_tags.moderated.reduce(result) do |memo, tag|
      memo <<
        "#{property.country_path_by_supertype}?by_tags=#{tag.id}"
          .then { |tag_url| link_to_unless(options[:no_link], tag.title, tag_url, target: :_blank, rel: :nofollow) }
          .then { |filter_link| "<li>#{filter_link}</li>" }
    end
      .then { |result| "<ul class='property-features checkboxes margin-top-0'>#{result}</ul>" if result.present? }
      .then { |list| "<h3 class='desc-headline'>#{t(:features, scope: :common)}</h3>#{list}" if list.present? }
      &.html_safe
  end

  def frontend_property_url(property)
    "https://#{Rails.application.default_url_options[:host]}#{property&.seo_path}"
  end

  def property_noindex?(property)
    # Разрешаем индексировать Grekodom
    !(property.agency_id == 450 && property.is_active? && property.moderated?)
  end

  def property_image(property)
    photo = photos_version(property)
    photo.empty? ? asset_pack_path('images/listing-01.jpg') : photo.first
  end

  private
    def get_energy_efficiency_pic(energy_efficiency_type)
      return unless energy_efficiency_type.to_i.in? Property::ENERGY_EFFICIENCY_TYPES.values
      "images/#{energy_efficiency_type}.png"
    end

    def get_youtube_video_link(link)
      regex =
        if 'youtu.be'.in?(link)
          # https://youtu.be/IhTXDklRLME
          /(?<=youtu\.be\/)[\w-]+\/?$/
        elsif 'youtube.com'.in?(link)
          # https://m.youtube.com/watch?v=IhTXDklRLME
          # https://www.youtube.com/watch?v=K9TRaGNnjEU&has_verified=1
          /(?<=watch\?v=)[\w-]+\/?/
        end

      return link if regex.blank?

      result = regex.match(link)

      return link if result.blank?

      "https://www.youtube.com/embed/#{result[0]}?rel=0&amp;showinfo=0"
    end

    def features_to_list(features, **options)
      return unless features

      features.reduce('') do |memo, feature|
        memo << "<li>#{t(feature.first, scope: :properties)}: <span>#{feature.last}</span></li>"
        # memo << list_item(t(feature.first, scope: :properties), feature.last)
      end.then do |result|
        "<ul class='#{options[:class]}'>#{result}</ul>" if result.present?
      end
    end
end
