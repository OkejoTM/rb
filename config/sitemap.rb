SitemapGenerator::Sitemap.default_host = "https://#{Rails.application.default_url_options[:host]}"
SitemapGenerator::Sitemap.create_index = true
SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'

SitemapGenerator::Sitemap.create do

  page_lastmod_limit = 40.days.ago
  host = SitemapGenerator::Sitemap.default_host
  locale_was = I18n.locale

  # Главная страница на всех языках
  I18n.available_locales.each do |locale|
    add(locale.to_s, priority: 0.9, changefreq: nil, lastmod: nil)
  end

  # Страницы недвижимости/категории недвижимости в стране, регионе, городе и по миру на всех языках
  # Страницы категорий недвижимости на всех языках
  property_supertypes = PropertySupertype.all
  property_supertypes.each do |supertype|
    I18n.available_locales.each do |locale|
      I18n.locale = locale
      add(supertype.seo_path,
          priority: 0.8,
          changefreq: nil,
          lastmod: nil,
          alternates: I18n.available_locales.reject { |l| l == locale }.map do |alt_locale|
            I18n.locale = alt_locale
            { href: host + supertype.seo_path, lang: alt_locale }
          end)
    end
  end

  # SEO-страницы недвижимости недвижимости в стране, регионе, городе на всех языках
  seo_templates = SeoTemplate.secondary
  seo_templates.each do |template|
    I18n.available_locales.each do |locale|
      I18n.locale = locale
      seo_paths = SeoTemplatesContainer.new(template).seo_paths
      seo_paths.each do |seo_path|
        add(seo_path,
            priority: 0.7,
            changefreq: nil,
            lastmod: template.updated_at > page_lastmod_limit ? template.updated_at.strftime('%Y-%m-%d') : nil,
            alternates: I18n.available_locales.reject { |l| l == locale }.map do |alt_locale|
              I18n.locale = alt_locale
              { href: host + seo_path, lang: alt_locale }
            end)
      end
    end
  end

  # SEO-страницы недвижимости/категорий недвижимости в стране, регионе, городе на всех языках
  seo_templates = SeoTemplate.primary
  seo_templates.each do |template|
    I18n.available_locales.each do |locale|
      I18n.locale = locale
      template.seo_location_pages.select { |page| page.try(:active?) }.each do |page|
        seo_path = page.seo_path
        add(seo_path,
            priority: 0.7,
            changefreq: nil,
            lastmod: template.updated_at > page_lastmod_limit ? template.updated_at.strftime('%Y-%m-%d') : nil,
            alternates: I18n.available_locales.reject { |l| l == locale }.map do |alt_locale|
              I18n.locale = alt_locale
              { href: host + seo_path, lang: alt_locale }
            end)
      end
    end
  end

  # Остальные страницы("О сайте", "Агентства" и т.д.) на всех языках
  # Страницы стран, регионов, городов на всех языках
  [Country, Region, City].each do |klass|
    objects = Object.const_get(klass.name).active
    objects.each do |object|
      I18n.available_locales.each do |locale|
        I18n.locale = locale
        add(object.seo_path,
            priority: 0.6,
            changefreq: nil,
            lastmod: object.updated_at > page_lastmod_limit ? object.updated_at.strftime('%Y-%m-%d') : nil,
            alternates: I18n.available_locales.reject { |l| l == locale }.map do |alt_locale|
              I18n.locale = alt_locale
              { href: host + object.seo_path, lang: alt_locale }
            end)
      end
    end
  end

  # Страница "Агентства" на всех языках
  I18n.available_locales.each do |locale|
    add(UrlsHelper.frontend_agencies_path,
        priority: 0.6,
        changefreq: nil,
        lastmod: nil,
        alternates: I18n.available_locales.reject { |l| l == locale }.map do |alt_locale|
          { href: host + UrlsHelper.frontend_agencies_path, lang: alt_locale }
        end)
  end

  # Страницы "Агентства" на всех языках в локациях
  seo_agencies_pages = SeoAgenciesPage.active
  seo_agencies_pages.each do |page|
    I18n.available_locales.each do |locale|
      I18n.locale = locale
      add(page.seo_path,
          priority: 0.6,
          changefreq: nil,
          lastmod: nil,
          alternates: I18n.available_locales.reject { |l| l == locale }.map do |alt_locale|
            I18n.locale = alt_locale
            { href: host + page.seo_path, lang: alt_locale }
          end)
    end
  end

  # Основные страницы агентств на всех языках
  seo_agency_pages = SeoAgencyPage.active.where.not(default_page_id: nil).eager_load(:agency)
  seo_agency_pages.each do |page|
    I18n.available_locales.each do |locale|
      I18n.locale = locale
      add(page.seo_path,
          priority: 0.6,
          changefreq: nil,
          lastmod: page.agency.updated_at > page_lastmod_limit ? page.agency.updated_at.strftime('%Y-%m-%d') : nil,
          alternates: I18n.available_locales.reject { |l| l == locale }.map do |alt_locale|
            I18n.locale = alt_locale
            { href: host + page.seo_path, lang: alt_locale }
          end)
    end
  end

  # Страница "Статьи" на всех языках
  I18n.available_locales.each do |locale|
    add(UrlsHelper.frontend_articles_path,
        priority: 0.6,
        changefreq: nil,
        lastmod: nil,
        alternates: I18n.available_locales.reject { |l| l == locale }.map do |alt_locale|
          { href: host + UrlsHelper.frontend_articles_path, lang: alt_locale }
        end)
  end

  # Страницы "Статьи" на всех языках
  articles = Article.active

  # Страницы "Статьи" на всех языках в категориях статей
  articles.where.not(article_category_id: nil).where(country_id: nil).each do |article|
    I18n.available_locales.each do |locale|
      I18n.locale = locale

      add(article.seo_category_path,
          priority: 0.6,
          changefreq: nil,
          lastmod: nil,
          alternates: I18n.available_locales.reject { |l| l == locale }.map do |alt_locale|
            I18n.locale = alt_locale
            { href: host + article.seo_category_path, lang: alt_locale }
          end)
    end
  end

  # Страницы "Статьи" на всех языках в странах
  articles.where.not(country_id: nil).where(article_category_id: nil).each do |article|
    I18n.available_locales.each do |locale|
      I18n.locale = locale

      add(article.seo_country_path,
          priority: 0.6,
          changefreq: nil,
          lastmod: nil,
          alternates: I18n.available_locales.reject { |l| l == locale }.map do |alt_locale|
            I18n.locale = alt_locale
            { href: host + article.seo_country_path, lang: alt_locale }
          end)
    end
  end

  # Страницы "Статьи" на всех языках в категориях и странах
  articles.where.not(country_id: nil, article_category_id: nil).each do |article|
    I18n.available_locales.each do |locale|
      I18n.locale = locale

      add(article.seo_category_in_country_path,
          priority: 0.6,
          changefreq: nil,
          lastmod: nil,
          alternates: I18n.available_locales.reject { |l| l == locale }.map do |alt_locale|
            I18n.locale = alt_locale
            { href: host + article.seo_category_in_country_path, lang: alt_locale }
          end)
    end
  end

  # Основные страницы статей на всех языках
  articles.each do |article|
    I18n.available_locales.each do |locale|
      I18n.locale = locale
      add(article.seo_path,
          priority: 0.6,
          changefreq: nil,
          lastmod: nil,
          alternates: I18n.available_locales.reject { |l| l == locale }.map do |alt_locale|
            I18n.locale = alt_locale
            { href: host + article.seo_path, lang: alt_locale }
          end)
    end
  end

  # Недвижимость Grekodom
  Agency.find(450).properties.active_and_moderated.each do |property|
    I18n.available_locales.each do |locale|
      I18n.locale = locale
      add(property.seo_path,
          priority: 0.5,
          changefreq: nil,
          lastmod: nil,
          alternates: I18n.available_locales.reject { |l| l == locale }.map do |alt_locale|
            I18n.locale = alt_locale
            { href: host + property.seo_path, lang: alt_locale }
          end)
    end
  end

  I18n.locale = locale_was
end
