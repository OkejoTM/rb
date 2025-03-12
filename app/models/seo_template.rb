# == Schema Information
#
# Table name: seo_templates
#
#  id                     :bigint           not null, primary key
#  created_by             :integer
#  filter_params          :json             not null
#  is_main                :boolean          default(FALSE)
#  link_name_en           :string
#  link_name_ru           :string
#  name                   :string
#  slug                   :string
#  template_location_type :integer          default(0)
#  updated_by             :integer
#  view_mode              :integer          default(0)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  property_supertype_id  :integer
#  property_type_group_id :integer
#  property_type_id       :integer
#  seo_templates_group_id :bigint           indexed
#

class SeoTemplate < ApplicationRecord
  #@!group Режимы отображения
  # Стандартный
  VIEW_MODE_DEFAULT = 0
  # Карта
  VIEW_MODE_MAP = 1
  #@!endgroup

  #@!group Типы объектов (локаций)
  # Весь мир
  TYPE_WORLD = 0
  # Страны
  TYPE_COUNTRIES = 1
  # Регионы
  TYPE_REGIONS = 2
  # Города
  TYPE_CITIES = 3
  # Водоемы
  TYPE_WATER = 4
  # Побережья
  TYPE_COASTS = 5
  # Горы
  TYPE_MOUNTAINS = 6
  # Достопримечательности
  TYPE_SIGHTS = 7
  #@!endgroup

  include Localizable
  include UserstampModule
  include Filterable
  include ScopeModule

  filter_params :view_mode, :template_location_type,
                :property_supertype_id, :property_type_group_id, :property_type_id

  has_one :seo_template_page, dependent: :destroy
  has_many :seo_location_pages, through: :seo_template_page

  has_many :seo_templates_areas, dependent: :nullify
  with_options through: :seo_templates_areas, source: :locatable do
    has_many :cities, source_type: 'City'
    has_many :regions, source_type: 'Region'
    has_many :countries, source_type: 'Country'
  end

  belongs_to :property_supertype
  belongs_to :property_type_group
  belongs_to :property_type

  belongs_to :seo_templates_group

  has_and_belongs_to_many :property_tags

  accepts_nested_attributes_for :seo_template_page, allow_destroy: true, reject_if: :all_blank

  default_scope { order(is_main: :desc, name: :asc) }
  scope :primary, -> { where(is_main: true) }
  scope :secondary, -> { where(is_main: false) }

  scopes_with_value :view_mode, :template_location_type,
                    :property_supertype_id, :property_type_group_id, :property_type_id

  validates :slug, uniqueness: { scope: :template_location_type }, slug: true, unless: :is_main?

  validates :name, presence: { message: 'Название не указано' }

  before_save :cleanup_filter_params
  after_save :update_seo_pages

  translate_fields :link_name

  class << self
    # Возвращает базовый сео-шаблон для коммерческой недвижимости
    # @return [SeoTemplate]
    def commercial_main
      SeoTemplate.find_by(slug: [nil, ''],
                        property_supertype_id: PropertySupertype::COMMERCIAL,
                        is_main: true)
    end

    # Возвращает базовый сео-шаблон для жилой недвижимости
    # @return [SeoTemplate]
    def residential_main
      SeoTemplate.find_by(slug: [nil, ''],
                        property_supertype_id: PropertySupertype::RESIDENTIAL,
                        is_main: true)
    end

    # Возвращает базовый сео-шаблон для земельных участков
    # @return [SeoTemplate]
    def land_main
      SeoTemplate.find_by(slug: [nil, ''],
                        property_supertype_id: PropertySupertype::LAND,
                        is_main: true)
    end

    # Возвращает базовый сео-шаблон для стран
    # @return [SeoTemplate]
    def country_main
      SeoTemplate.find_by(slug: [nil, ''],
                        template_location_type: SeoTemplate::TYPE_COUNTRIES,
                        is_main: true)
    end

    # Возвращает базовый сео-шаблон для регионов
    # @return [SeoTemplate]
    def region_main
      SeoTemplate.find_by(slug: [nil, ''],
                        template_location_type: SeoTemplate::TYPE_REGIONS,
                        is_main: true)
    end

    # Возвращает базовый сео-шаблон для городов
    # @return [SeoTemplate]
    def city_main
      SeoTemplate.find_by(slug: [nil, ''],
                        template_location_type: SeoTemplate::TYPE_CITIES,
                        is_main: true)
    end

    # Возвращает базовый сео-шаблон в соответствии с типом объектов (локаций)
    # nil, если базовый сео шаблон для локации не найден
    # @param template_location_type [Integer] тип локации
    # @return [SeoTemplate]
    def default_by_location_type(template_location_type)
      case template_location_type
        when TYPE_COUNTRIES
          country_main
        when TYPE_REGIONS
          region_main
        when TYPE_CITIES
          city_main
        else
          nil
      end
    end

    # Возвращает базовый сео-шаблон в соответствии с категорией недвижимости
    # nil, если базовый сео шаблон для локации не найден
    # @param property_supertype_id [Integer] категория недвижимости
    # @return [SeoTemplate]
    def default_by_property_supertype(property_supertype)
      case property_supertype
        when PropertySupertype::COMMERCIAL
          commercial_main
        when PropertySupertype::RESIDENTIAL
          residential_main
        when PropertySupertype::LAND
          land_main
        else
          nil
      end
    end
  end

  # Возвращает найденную по area SEO-страницу, либо создаёт новую
  # @param area [Area] страна/регион/город
  # @return [SeoLocationPage] страница по SEO-шаблону
  def get_seo_page(area = nil)
    if area.present?
      page = seo_location_pages.find_by(object_id: area.id, object_type: area.class.to_s, default_page_id: seo_template_page.id)
      return page if page.present?

      page = SeoLocationPage.create!(object: area,
                                     default_page_id: seo_template_page.id)
      reload
      page
    else
      seo_template_page
    end
  end

  # Количество сео страниц сео шаблона
  def pages_count
    l = locations.to_a
    return l.count if l.present?
    0
  end

  # Список локаций (страна/регионов/городов) в соответствии с заданным в сео шаблоне типом расположения
  def locations
    # У главных сео шаблонов нет локаций,
    # они относятся сразу ко всем локациям заданного типа
    case template_location_type
      when TYPE_COUNTRIES
        is_main? ? Country.all : countries
      when TYPE_REGIONS
        is_main? ? Region.all : regions
      when TYPE_CITIES
        is_main? ? City.all : cities
      else
        []
    end
  end

  # Очищает все локации сео шаблона
  def clear_locations
    self.countries.build([])
    self.regions.build([])
    self.cities.build([])
  end

  # Режим отображения по-умолчанию?
  def view_mode_default?
    view_mode == VIEW_MODE_DEFAULT
  end

  # Режим отображения на карте?
  def view_mode_map?
    view_mode == VIEW_MODE_MAP
  end

  # Задано ли значение параметр фильтра?
  def has_param?(param_name)
    filter_params[param_name.to_s].present?
  end

  # Задано ли значение хотя бы одного параметра фильтра?
  def has_params?(param_names)
    filter_params.select { |_, v| v.present? }.keys.any? { |key| param_names.include?(key.to_sym) }
  end

  # Непустые параметры фильтра
  def presented_filter_params
    filter_params.select { |_, v| !v.in?(['', nil]) }
  end

  # Параметры, участвующие в фильтрации недвижимости
  def params_for_filter
    filter_params.merge(types_group: self.property_type_group_id, type: self.property_type_id)
  end

  private
    #@!group Коллбэки

    # Коллбэк для приведения в порядок параметров фильтра
    def cleanup_filter_params
      if filter_params.present?
        self.filter_params = filter_params.map { |k, v| { k => (v.kind_of?(Array) ? v.reject(&:empty?) : v) } }.reduce(:merge)
      end
    end

    # Callback для обновления параметров всех сео страниц (количества недвижимости)
    def update_seo_pages
      if filter_params_changed?
        self.seo_location_pages.each(&:save)
      end
    end

  #@!endgroup
end
