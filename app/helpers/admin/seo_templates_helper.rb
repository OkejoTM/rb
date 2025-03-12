module Admin::SeoTemplatesHelper
  def template_property_type(template)
    if template.property_type.present?
      template.property_type.title
    elsif template.property_supertype.present?
      template.property_supertype.title
    else
      t(:show, scope: :properties)
    end
  end

  # Возвращает хэш с режимами отображения страницы
  # @return [Hash]
  def template_view_modes
    {
        'Стандартный' => SeoTemplate::VIEW_MODE_DEFAULT,
        'Карта' => SeoTemplate::VIEW_MODE_MAP
    }
  end

  # Возвращает хэш с типами локаций
  # @return [Hash]
  def template_location_types
    {
        'Весь мир' => SeoTemplate::TYPE_WORLD,
        'Страны' => SeoTemplate::TYPE_COUNTRIES,
        'Регионы' => SeoTemplate::TYPE_REGIONS,
        'Города' => SeoTemplate::TYPE_CITIES,
        'Водоемы' => SeoTemplate::TYPE_WATER,
        'Побережья' => SeoTemplate::TYPE_COASTS,
        'Горы' => SeoTemplate::TYPE_MOUNTAINS,
        'Достопримечательности' => SeoTemplate::TYPE_SIGHTS
    }
  end

  def template_location_type_name(template)
    template_location_types.key(template.template_location_type)
  end

  # Сортирует по алфавиту, базовые страницы имеют больший приоритет
  def sort_seo_location_pages(seo_location_pages)
    seo_location_pages.sort do |slp1, slp2|
      (slp1.seo_template.name <=> slp2.seo_template.name) * (slp1.primary? ? -1 : 1)
    end
  end
end
