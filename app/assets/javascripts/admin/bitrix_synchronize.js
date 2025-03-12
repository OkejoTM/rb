import { noty_success, noty_error } from "./init_noty";

$(function() {
  $('[role="bitrix-synchronize-btn"]').on('click', function () {
    let $this = $(this);

    if($this.attr('disabled')) { return; }

    let bid_id = $this.data('bid-id');
    let bid_type = $this.data('bid-type');

    $.ajax({
      method: 'POST',
      url: '/bitrix/synchronize',
      dataType: 'json',
      data: {
        bid_id: bid_id,
        bid_type: bid_type
      },
      beforeSend: () => {
        $this.attr('disabled', true);
      }
    }).done((data) => {
      $this.hide();
      noty_success(data['notice']);
      let icon = $($this).parents('tr').find('.fa-exclamation');
      icon.addClass('fa-hourglass-half text-warning');
      icon.removeClass('text-danger fa-exclamation');

    }).fail((data) => {
      noty_error(data.responseJSON['notice']);
    }).always(() => {
      $this.attr('disabled', false);
    })

  });
});
