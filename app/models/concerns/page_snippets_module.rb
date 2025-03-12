module PageSnippetsModule
  extend ActiveSupport::Concern

  included do
    class << self
      def enable_snippets_for(fields_for:)
        fields_for.each do |field|
          define_method(field) do
            tmp = self.__getobj__.send(field) # работает для декораторов, где self.__getobj__ - декорируемый объект
            # tmp = self.instance_method(field).bind(self).call
            # tmp = self.instance_eval("#{field}")
            # tmp = SeoTemplate.instance_method(field).bind(self.__getobj__).call
            if tmp.present?
              tmp.gsub(/\{(.*?)\}/) do
                if PageSnippetsModule.instance_methods(false).include?($1.to_sym)
                  send($1.to_sym)
                else
                  "{#{$1}}"
                end
              end
            elsif @area.present?
              # @area.send("page_#{field}")
              ''
            end
          end
        end
      end
    end
  end

  # @return [String] поле H1
  def h1
    res = super.presence || self.try(:default_page).h1.presence
    apply_snippets(res)
  end

  # @return [String] заголовок страницы
  def title
    res = super.presence || self.try(:default_page)&.title.presence
    apply_snippets(res)
  end

  # @return [String] мета-описание
  def meta_description
    res = super.presence || self.try(:default_page)&.meta_description.presence
    apply_snippets(res)
  end

  # @return [String] описание страницы
  def description
    res = super.presence || self.try(:default_page)&.description.presence
    apply_snippets(res)
  end


  # Snippets
  def year
    Date.today.year
  end

  def year_next
    (Date.today + 1.year).year
  end

  def year_tactical
    Date.today.month < 10 ? Date.today.year : "#{Date.today.year} - #{Date.today.next_year.year}"
  end

  def area_name
    @area&.title
  end

  def area_genitive
    @area&.title_genitive
  end

  def area_locative
    @area&.title_prepositional
  end

  def area_full_name_locative
    @area&.full_name_locative
  end


  # Только для города
  def area_region_name
    @area.try(:region)&.title
  end

  # Только для города
  def area_region_genitive
    @area.try(:region)&.title_genitive
  end

  # Только для города
  def area_region_locative
    @area.try(:region)&.title_prepositional
  end

  # Только для города
  def area_region_full_name_locative
    @area.try(:region)&.full_name_locative
  end


  # Только для города и региона
  def area_country_name
    @area.try(:country)&.title
  end

  # Только для города и региона
  def area_country_genitive
    @area.try(:country)&.title_genitive
  end

  # Только для города и региона
  def area_country_locative
    @area.try(:country)&.title_prepositional
  end

  # Только для города и региона
  def area_country_full_name_locative
    @area.try(:country)&.full_name_locative
  end

  def properties_count
    # @area.active_and_moderated_properties_count
    self[:properties_count]
  end


  # Для агентств
  delegate :name, to: :agency, prefix: true

  def priority_country_title
    agency.priority_country&.title
  end


  private

    def apply_snippets(str)
      if str.present?
        str.gsub(/\{(.*?)\}/) do
          if PageSnippetsModule.instance_methods(false).include?($1.to_sym)
            send($1.to_sym)
          else
            "{#{$1}}"
          end
        end
      elsif @area.present?
        ''
      end
    end
end
