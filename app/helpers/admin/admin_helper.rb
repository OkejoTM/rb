module Admin::AdminHelper
  def setup_contact_person(contact_person)
    contact_person.contacts.build
    contact_person
  end

  def setup_seo_template(template)
    template.build_seo_template_page if template.seo_template_page.blank?
    template
  end

  # Рендеринг пагинации
  def render_pagination(pagination)
    render partial: 'admin/common/pagination', locals: { pagination: pagination }
  end

  def render_location_filter(location_filter:, type:)
    render partial: 'admin/common/location_filter', locals: { location_filter: location_filter, type: type }
  end

  def render_bids_filter(search_url:)
    render partial: 'admin/common/bids_filter', locals: { search_url: search_url }
  end

  def render_property_filter(search_url:)
    render partial: 'admin/common/property_filter', locals: { search_url: search_url }
  end

  def render_user_filter(search_url:)
    render partial: 'admin/common/user_filter', locals: { search_url: search_url }
  end

  def render_agency_filter(search_url:)
    render partial: 'admin/common/agency_filter', locals: { search_url: search_url }
  end

  def render_compact_control_buttons(obj:,
                                     edit_obj_path:,
                                     confirm_message: nil,
                                     hide_show_btn: false,
                                     hide_delete_btn: false,
                                     show_obj_path: nil)
    render partial: 'admin/common/compact_control_buttons',
           locals: {
               obj: obj,
               hide_show_btn: hide_show_btn,
               hide_delete_btn: hide_delete_btn,
               show_obj_path: show_obj_path,
               edit_obj_path: edit_obj_path,
               confirm_message: confirm_message
           }
  end

  def render_control_buttons(form:, obj:, hide_show_btn: false, confirm_message:, show_obj_path: nil)
    render partial: 'admin/common/control_buttons',
           locals: {
               form: form,
               obj: obj,
               show_obj_path: show_obj_path,
               hide_show_btn: hide_show_btn,
               confirm_message: confirm_message
           }
  end

  def render_location_alter_names(form:)
    render partial: "admin/common/location_alter_names", locals: { form: form }
  end

  def render_location_form(form:)
    render partial: 'admin/common/location_form', locals: { form: form }
  end

  def render_location_seo_pages(form:, location:)
    render partial: "admin/common/location_seo_pages", locals: { form: form, location: location }
  end

  def render_location_show(location)
    render partial: 'admin/common/location_show', locals: { location: location }
  end

  def render_loader(id)
    render partial: 'admin/common/loader', locals: { id: id }
  end

  def render_comments(obj, comments)
    render partial: 'admin/common/comments', locals: { obj: obj, comments: comments }
  end

  def maintenance_status
    File.exist?(Rails.root.join('deploy')) ? render(partial: 'admin/common/maintenance_alert') : ''
  end

  def switch_off_simulate_mode_btn
    return unless current_user.simulation_mode_on?

    link_to('Выйти из режима симуляции',
            out_simulation_mode_path,
            class: 'btn btn-xs btn-danger',
            style: 'position: fixed; right: 20px; bottom: 20px;'
    )
  end

  # Описание сниппетов, генерируемое из локализации
  # @param [String, Symbol] namespace
  # @param [String, Symbol] snippet_type
  # @return [String]
  def snippets_description(namespace, snippet_type = nil, separator: '<br>')
    locale_key = ['snippets', namespace, snippet_type].join('.')
    t(locale_key).map { |name, desc| "{#{name}} - #{desc}" }.join(separator).html_safe
  end

  # Возвращает разметку кнопки для формы поиска/фильтрации
  def search_button(options = {})
    "<button type='submit' class='btn btn-default' id='search_btn' style='#{options[:style]}'>
        <i class='glyphicon glyphicon-search'></i>
    </button>".html_safe
  end

  # Генерирует пункт меню навбара
  # @param [String] _link_name название ссылки
  # @param [String] _link_path путь для ссылки
  # @param [String] _controller_name имя контроллера, на который ведет ссылка
  # @param [String] _action_name имя экшэна, который обрабатывает ссылку
  # @param [Int] _notification_amount число уведомлений по меню навбара
  # @return [String]
  def navbar_link(_link_name:, _link_path:, _controller_name:, _action_name: nil, _notification_amount: nil)
    return unless allowed_to?(:show, _controller_name.to_s.singularize.to_sym)

    active = controller_name == _controller_name && (_action_name.blank? || action_name == _action_name)
    unless _notification_amount.nil?
      if _notification_amount.positive?
        label = '<span class="badge badge-danger">+' + _notification_amount.to_s + '</span>'
      end
    end

    "<li #{'class=active' if active}>
      #{link_to "#{_link_name} #{label}".html_safe, _link_path, target: '_self'}
     </li>".html_safe
  end

  # Bootstrap 3 progress bar
  # @param [Integer] percent - процент, который должен быть отображен в прогресс баре
  # @return [String]
  def progress_bar(percent)
    <<-HTML.html_safe
    <div class="progress">
      <div class="progress-bar progress-bar-#{color_by_percent(percent)}"
           role="progressbar"
           aria-valuenow="#{percent}"
           aria-valuemin="0"
           aria-valuemax="100"
           style="min-width: 2em; width: #{percent}%;">
        #{percent}%
      </div>
    </div>
    HTML
  end

  # Bootstrap 3 класс с цветом для прогресс бара
  # @param [Integer] percent - процент от 0 до 100
  # @return [String]
  def color_by_percent(percent)
    case percent
      when 0..10
        'danger'
      when 11..50
        'warning'
      when 51..90
        'primary'
      when 91..100
        'success'
    end
  end
end
