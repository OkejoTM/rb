module UrlsHelper
  extend(self)

  def create_uri(base_url)
    BasicUri.new(base_url)
  end

  def residential_path
    "/#{I18n.locale}/residential"
  end

  def commercial_path
    "/#{I18n.locale}/commercial"
  end

  def land_path
    "/#{I18n.locale}/land"
  end


  def frontend_agencies_path
    "/#{I18n.locale}/agencies"
  end

  def frontend_country_agencies_path(country_slug)
    "#{frontend_agencies_path}/c/#{country_slug}"
  end

  def frontend_region_agencies_path(country_slug, region_slug)
    "#{frontend_agencies_path}/c/#{country_slug}/r/#{region_slug}"
  end

  def frontend_city_agencies_path(country_slug, city_slug)
    "#{frontend_agencies_path}/c/#{country_slug}/c/#{city_slug}"
  end


  def frontend_articles_path
    "/#{I18n.locale}/articles"
  end

  def frontend_country_articles_path(country_slug)
    "/#{I18n.locale}/articles/#{country_slug}"
  end

  def frontend_article_category_articles_path(article_category_slug)
    "/#{I18n.locale}/articles/#{article_category_slug}"
  end

  def frontend_article_category_and_country_articles_path(country_slug, article_category_slug)
    "/#{I18n.locale}/articles/#{country_slug}/#{article_category_slug}"
  end

  def frontend_favorites_path
    "/#{I18n.locale}/favorites"
  end

  def compare_properties_path
    "/#{I18n.locale}/compare_properties"
  end
end
