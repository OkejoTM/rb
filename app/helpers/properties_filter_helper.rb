# TODO зарефакторить, объединить с filter options
module PropertiesFilterHelper
  def value_for_filter(property_name, template)
    if params[property_name].present?
      params[property_name]
    elsif template.present?
      template.filter_params[property_name.to_s]
    end
  end

  def checkbox_value_for_filter(property_name, template)
    if params[property_name].present?
      params[property_name]
    elsif template.present?
      template.filter_params[property_name.to_s] == 'on'
    end
  end

  # Используется ли заданный тег на ткущей странице с учетом сео шаблона?
  def property_tags_for_filter(property_tag_id, template)
    params['by_tags']&.include?(property_tag_id.to_s) || template&.property_tag_ids&.include?(property_tag_id)
  end

  def active_currency_options_for_filter
    CurrencyRate::ACTIVE_CURRENCIES.map do |currency|
      [CurrencyRate.currency_symbol(currency), currency]
    end
  end

  def properties_filter_active
    {
        I18n.t(:active_short, scope: :properties) => "true",
        I18n.t(:not_active_short, scope: :properties) => "false"
    }
  end

  def properties_filter_moderated
    {
        I18n.t(:moderated_short, scope: :properties) => "true",
        I18n.t(:not_moderated_short, scope: :properties) => "false"
    }
  end

  def properties_filter_sort_options
    {
        I18n.t(:created_at, scope: :sort) => "created_at",
        I18n.t(:updated_at, scope: :sort) => "updated_at",
        I18n.t(:created_at_desc, scope: :sort) => "created_at DESC",
        I18n.t(:updated_at_desc, scope: :sort) => "updated_at DESC"
    }
  end

  def type_group_by_params(params, template)
    if params[:types_group].present?
      params[:types_group].to_i
    elsif template.present?
      template.property_type_group_id
    end
  end

  def type_by_params(params, template)
    if params[:type].present?
      params[:type].to_i
    elsif template.present?
      template.property_type_id
    end
  end

  # Создает тег select, содержащий option с вариантом "Любой" и option, сгруппированные в optgroup
  def select_with_optgroups(name, type_groups, selected_type_group, **options)
    css_class = options.fetch(:class, nil)

    result =
    "<select name='#{name}' id='#{name}' class='#{css_class}'>
      <option value='0'>#{I18n.t(:any_properties, scope: :common)}</option>"
    type_groups.each do |type_group|
      result += "<optgroup label='#{type_group[0]}'>"

      type_group[1].each do |group|
        result += "<option value='#{group.id}' #{'selected' if group.id == selected_type_group}>#{group.title}</option>"
      end

      result += "</optgroup>"
    end
    result += "</select>"
    result.html_safe
  end

  def photos_version(property)
    Browser.new(request.user_agent).device.mobile? ? property.mini_pics_urls : property.middle_pics_urls
  end

  def photos_version_slider(property)
    Browser.new(request.user_agent).device.mobile? ? property.middle_pics_urls : property.pics_urls
  end
end
