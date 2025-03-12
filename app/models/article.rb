# == Schema Information
#
# Table name: articles
#
#  id                   :bigint           not null, primary key
#  created_by           :integer
#  description_en       :text             default("")
#  description_ru       :text             default("")
#  h1_en                :string
#  h1_ru                :string
#  is_active            :boolean          default(FALSE)
#  meta_description_en  :text             default("")
#  meta_description_ru  :text             default("")
#  short_description_en :text             default("")
#  short_description_ru :text             default("")
#  slug                 :string
#  title_en             :string
#  title_ru             :string
#  updated_by           :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  article_category_id  :bigint           indexed
#  country_id           :bigint           indexed
#

class Article < ApplicationRecord
  include Localizable
  include Pictureable

  belongs_to :article_category
  belongs_to :country

  scope :active, -> { where("articles.is_active = true") }
  scope :inactive, -> { where("articles.is_active = false") }

  scope :with_translate, -> (locale) { where.not("description_#{locale}": ['', nil]) }
  scope :visible, -> (locale) { active.with_translate(locale) }

  validates :article_category_id, uniqueness: { scope: :country_id }
  validates :slug, allow_blank: true, uniqueness: { scope: [:article_category_id, :country_id] }, slug: true

  after_commit :handle_images, on: [:create, :update]

  translate_fields :h1, :title, :meta_description, :short_description, :description

  # URL к статье
  # @return [String] URL к статье
  def seo_path
    country_url = "/#{country.slug}" if country.present?
    article_category_url = "/#{article_category.slug}" if article_category.present?

    result = "/#{I18n.locale}/articles#{country_url}#{article_category_url}"

    return "#{result}/#{slug}" if slug.present?
    result
  end

  # URL к статьям в категории
  # @return [String] URL к статьям в категории
  def seo_category_path
    "/#{I18n.locale}/articles/#{article_category.slug}" if article_category.present?
  end

  # URL к статьям в стране
  # @return [String] URL к статьям в стране
  def seo_country_path
    "/#{I18n.locale}/articles/#{country.slug}" if country.present?
  end

  # URL к статьям в категории страны
  # @return [String] URL к статьям в категории страны
  def seo_category_in_country_path
    "/#{I18n.locale}/articles/#{country.slug}/#{article_category.slug}" if country.present? && article_category.present?
  end

  protected

    def handle_images
      # Достать ссылки на картинки из описаний
      pic_url_regex = /(?<=<img src=\").*?(?=\">)/
      pic_urls = (self.description_ru + self.description_en).scan(pic_url_regex).to_a.uniq

      # Отвязать все картинки от статьи, чтобы позже очистить удаленные из текста
      self.pictures.update_all(imageable_type: nil, imageable_id: nil)

      if pic_urls.present?
        # Достать картинки, связанные со статьей, по ссылкам
        pictures = Picture.temporary.select do |picture|
          pic_urls.include?(picture.pic.url)
        end

        # Добавить картинки к статье
        self.pictures << pictures
      end
    end
end
