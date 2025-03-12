module Admin
  module BitrixHelper
    def bitrix_sync_state(bid)
      state =
          if bid.bitrix_synced_success?
            { class: 'success', icon: 'check' }
          elsif bid.bitrix_synced_fail?
            { class: 'danger', icon: 'exclamation' }
          else
            { class: 'warning', icon: 'hourglass-half' }
          end

      prompt = t("bitrix.#{state[:class]}")

      <<-HTML.html_safe
      <div title="#{prompt}">
        <i class="fas fa-#{state[:icon]} text-#{state[:class]}"></i>
      </div>
      HTML
    end

    # Возвращает HTML тэг ссылки на битрикс
    # @param [BaseBidPresenter] bid_presenter
    # @return [String]
    def link_to_bitrix(bid_presenter)
      return if bid_presenter.bitrix_id.blank? || !bid_presenter.bitrix_synced_success?

      link_to '<span class="bitrix-icon" aria-hidden="true"></span>'.html_safe,
              bid_presenter.bitrix_url,
              class: 'btn btn-default',
              title: t('bitrix.bitrix_link'),
              target: '_blank',
              style: 'padding: 5px 8px 2px 8px;'
    end

    def bitrix_sync_button(bid)
      return unless bid.bitrix_synced_fail?

      <<-HTML.html_safe
        <a class="btn btn-default"
           title="#{I18n.t('bitrix.synchronize')}"
           data-bid-id="#{bid.id}"
           data-bid-type="#{bid.class}"
           role='bitrix-synchronize-btn'
        >
          <i class="glyphicon glyphicon-refresh"></i>
        </a>
      HTML
    end
  end
end
