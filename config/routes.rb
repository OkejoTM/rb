require 'sidekiq/web'

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # get '/', to: redirect("/#{I18n.locale}")
  root to: 'frontend#index'

  devise_for :users

  scope module: :admin do
    get '/admin', to: 'admin#main'
    get '/search', to: 'admin#search'
    post '/image_upload', to: 'admin#image_upload'

    get '/out_simulation_mode', to: 'users#switch_off_simulate_mode'

    post '/bitrix/synchronize', to: 'bitrix#synchronize'

    scope :reports do
      get 'updated_content', to: 'reports#updated_content'
      get 'updated_content_result', to: 'reports#updated_content_result'
    end

    resources :users

    resources :countries, :regions, :cities do
      get :browse_pages
      collection do
        get :translations
      end
    end

    resources :agencies do
      get :show, constraints: lambda { |req| req.format == :json }
      collection do
        get :last
        get :translations
      end
    end

    resources :properties do
      collection do
        get :attributes
        get :same
        get :no_location
        get :far_property
        get :for_moderation
      end
    end

    resources :pictures, only: %i[destroy]

    resources :contact_people, only: [:index, :destroy]

    resources :contact_types
    resources :messenger_types
    resources :location_types
    resources :property_supertypes
    resources :property_type_groups
    resources :property_types
    resources :property_tag_categories
    resources :agency_types
    resources :articles, except: :show
    resources :article_categories
    resources :seo_templates_groups
    resources :pages, only: [:index, :edit, :update]
    resources :bids, only: [:index, :update, :destroy]
    resources :real_estate_parsers, only: [:index, :update] do
      post :start

      resources :real_estate_parser_logs, only: :index, controller: 'real_estate_parsers/real_estate_parser_logs' do
        get 'open_file/:id', to: 'files#open_in_browser', as: 'open_file'
      end
    end
    resources :agency_bids, only: %i[index destroy]
    resources :client_feedbacks, only: %i[index destroy]

    resources :property_tags do
      collection do
        patch :sort
      end
    end

    resources :seo_templates do
      get :browse_pages
      collection do
        get :area_fields_modal_content
        put :update_seo_page
        get :areas_index
        put :add_locations
        put :add_all_locations
        put :remove_locations
        put :remove_all_locations
      end
    end

    resources :seo_articles_pages, only: [:show, :edit, :update] do
      collection do
        get :edit_articles_main
        get :edit_articles_countries_main
        get :edit_articles_categories_main
      end
    end

    resources :seo_agencies_pages, only: [:show, :update] do
      collection do
        get :edit_agencies_main
      end
    end

    resources :seo_agency_pages, only: [:show, :update] do
      collection do
        get :edit_agency_main
      end
    end

    resources :comments, only: %i[index create destroy]

    authenticate :user, lambda { |u| u.admin? } do
      mount Sidekiq::Web => '/sidekiq'
    end
  end

  # match '*path', to: redirect("/#{I18n.locale}/%{path}"), constraints: lambda { |req|
  #   !req.path.starts_with?("/#{I18n.locale}/") && req.path != '/'
  # }, format: false, via: [:get, :post]

  scope ":locale", locale: /#{I18n.available_locales.join('|')}/ do
    # root to: 'frontend#index'
    get '/', to: 'frontend#index'

    get :best_deals, to: 'frontend#best_deals'
    get :favorites, to: 'frontend#favorites'
    get :compare_properties, to: 'frontend#compare_properties'

    post 'bids', to: 'bids#create_bid'
    post 'client_feedback', to: 'client_feedbacks#create_client_feedback'
    get :agency_bid_form, to: 'agency_bids#new_agency_bid'
    post :agency_bid_form, to: 'agency_bids#create_agency_bid'

    constraints Constraints::PropertySupertypeExistence.new do
      # get ':property_supertype', to: 'properties_filter#supertype'
      get ':property_supertype', to: 'properties_filter#properties'
      constraints Constraints::SeoTemplateExistence.new do
        # get ':property_supertype/f/:template_slug', to: 'properties_filter#supertype'
        get ':property_supertype/f/:template_slug', to: 'properties_filter#properties'
      end
    end

    # Страница сео-шаблона категории недвижимости
    constraints Constraints::SeoTemplateExistence.new do
      get ':country_url/f/:template_slug', to: 'properties_filter#properties'
    end

    get 'agencies', to: 'agencies_filter#agencies', as: 'agencies_list'

    constraints Constraints::AreaExistence.new do
      get 'agencies/c/:country_url', to: 'agencies_filter#agencies'
      get 'agencies/c/:country_url/r/:region_url', to: 'agencies_filter#agencies'
      get 'agencies/c/:country_url/c/:city_url', to: 'agencies_filter#agencies'
    end

    get 'agencies/:agency_url', to: 'frontend#agency', as: 'agencies_list_item'

    get 'articles', to: 'articles_filter#articles'#, as: 'articles_list'
    get 'articles_list', to: 'articles_filter#articles_list'#, as: 'articles_list'
    get 'articles/:country_or_category_url', to: 'articles_filter#articles'#, as: 'articles_list'
    constraints Constraints::AreaExistence.new do
      constraints Constraints::ArticleExistence.new do
        get 'articles/:country_url/:article_category_url', to: 'frontend#article'
      end
      get 'articles/:country_url/:article_category_url', to: 'articles_filter#articles'#, as: 'articles_list'
      get 'articles/:country_url/:article_category_url/:article_url', to: 'frontend#article', as: 'articles_list_item'
    end

    get 'autocomplete', to: 'frontend#autocomplete'
    get 'main_search', to: 'properties_filter#main_search'

    get 'properties_list', to: 'properties_filter#properties_list'
    get 'properties_for_map', to: 'properties_filter#properties_for_map'
    get 'property_for_map', to: 'properties_filter#property_for_map'

    get :terms, to: 'frontend#terms'
    get :privacy, to: 'frontend#privacy'

    constraints Constraints::GetParamsExistence.new do
      get ':country_url', to: 'properties_filter#properties'
    end

    get 'country_properties/:country_id', to: 'frontend#country_properties', as: :country_properties
    get ':country_url', to: 'frontend#country', as: :frontend_country
    constraints Constraints::PropertySupertypeExistence.new do
      get ':country_url/:property_supertype', to: 'properties_filter#properties'
      get ':country_url/r/:region_url/:property_supertype', to: 'properties_filter#properties'
      get ':country_url/c/:city_url/:property_supertype', to: 'properties_filter#properties'
    end

    get ':country_url/r/:region_url', to: 'properties_filter#properties'
    get ':country_url/c/:city_url', to: 'properties_filter#properties'
    get ':country_url/r/:region_url/:id', to: 'frontend#property'
    get ':country_url/c/:city_url/:id', to: 'frontend#property'
    get ':country_url/:id', to: 'frontend#property'

    # Страница сео-шаблона города
    constraints Constraints::SeoTemplateExistence.new do
      constraints Constraints::AreaExistence.new do
        get ':country_url/r/:region_url/f/:template_slug', to: 'properties_filter#properties'
        get ':country_url/c/:city_url/f/:template_slug', to: 'properties_filter#properties'
      end
    end
  end
end
