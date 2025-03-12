# Генерирует значения параметров фильтрации недвижимости, такие как количество спален, типов недвижимости и т.д.
class FilterOptions
  attr_accessor :current_page

  def initialize(supertype_id = nil)
    @supertype_id = supertype_id
  end

  def statuses
    [
        [I18n.t(:any_status, scope: :properties), 0],
        [I18n.t(:for_sale, scope: :properties), 1],
        [I18n.t(:for_rent, scope: :properties), 2]
    ]
  end

  def bedrooms
    [
        [I18n.t(:bedrooms_any, scope: :properties), 0],
        [1, 1],
        [2, 2],
        [3, 3],
        [4, 4],
        ["5+", 5]
    ]
  end

  def bathrooms
    [
        [I18n.t(:bathrooms_any, scope: :properties), 0],
        [1, 1],
        [2, 2],
        [3, 3],
        [4, 4],
        ["5+", 5]
    ]
  end

  def room_count
    [
        [I18n.t(:room_count_any, scope: :properties), -1],
        [I18n.t(:studio, scope: :properties), 0],
        [1, 1],
        [2, 2],
        [3, 3],
        [4, 4],
        ["5+", 5]
    ]
  end

  def types
    [[I18n.t(:any_feminine, scope: :common), 0]].concat(property_types_by_supertype)
  end

  def supertypes
    [
       [PropertySupertype.residential.title, PropertySupertype::RESIDENTIAL],
       [PropertySupertype.commercial.title, PropertySupertype::COMMERCIAL],
       [PropertySupertype.land.title, PropertySupertype::LAND]
    ]
  end

  def supertype
    PropertySupertype::SLUGS[@supertype_id]
  end

  def type_groups
    # [[I18n.t(:any_feminine, scope: :common), 0]].concat(property_type_groups_by_supertype)
    property_type_groups_by_supertype.group_by { |type_group| type_group.property_supertype.title }
  end

  def location_types
    # [[I18n.t(:any_neuter, scope: :common), 0]].concat(LocationType.all.map { |lt| [lt.title, lt.id] })
    LocationType.all.map { |lt| [lt.title, lt.id] }
  end


  # Все теги недвижимости у которых есть недвижимость
  def property_tags
    PropertyTag.visible.all.joins(:properties).distinct
  end

  # Общие (не относящиеся к категории недвижимости) теги недвижимости у которых есть недвижимость
  def common_property_tags
    PropertyTag.visible.common.joins(:properties).distinct
  end

  # Теги недвижимости в соответствии с заданной категорией недвижимости
  def property_tags_by_supertype
    PropertyTag.visible.by_property_supertype(@supertype_id).joins(:properties).distinct
  end

  # Общие теги + теги для заданной категории недвижимости, у которых есть недвижимость
  def all_property_tags
    common_property_tags.to_a.union(property_tags_by_supertype.to_a).sort_by(&:position)
  end


  def has_variations_of_types
    property_types_by_supertype.count > 1
  end

  def has_variations_of_type_groups
    property_type_groups_by_supertype.count > 1
  end

  # Метод-заглушка
  # Производится ли поиск недвижимости на продажу или в аренду
  # Истина - на продажу, ложь - в аренду
  def for_sale?
    true
  end

  def sort_by
    [
        [I18n.t(:default_order, scope: :sort), Property::SORT_DEFAULT],
        [I18n.t(:price_low_to_high, scope: :sort), Property::SORT_PRICE_LOW_TO_HIGH],
        [I18n.t(:price_high_to_low, scope: :sort), Property::SORT_PRICE_HIGH_TO_LOW]
    ]
  end

  def construction_phase
    [
        [I18n.t(:new_building, scope: :properties), Property::CONSTRUCTION_PHASE_NEW],
        [I18n.t(:off_plan, scope: :properties), Property::CONSTRUCTION_PHASE_OFF_PLAN],
        [I18n.t(:resale, scope: :properties), Property::CONSTRUCTION_PHASE_RESALE]
    ]
  end

  def residential?
    @supertype_id == PropertySupertype::RESIDENTIAL
  end

  def commercial?
    @supertype_id == PropertySupertype::COMMERCIAL
  end

  def land?
    @supertype_id == PropertySupertype::LAND
  end

private

  def property_types_by_supertype
    property_types =
        if @supertype_id.present?
          PropertySupertype.find(@supertype_id).property_types
        else
          PropertyType.all
        end

    property_types.map { |elem| [elem.title, elem.id] }
  end

  def property_type_groups_by_supertype
    # property_type_groups =
    if @supertype_id.present?
      PropertySupertype.find(@supertype_id).property_type_groups
    else
      PropertyTypeGroup.all
    end

    # property_type_groups.map { |elem| [elem.title, elem.id, elem.property_supertype.title] }
  end

end
