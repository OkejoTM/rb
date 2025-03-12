$(window).on('load', function () {
    $('input[data-bid-id]').click(function(e) {
        let bid_id = $(this).attr('data-bid-id');

        let $loading = $(`#loading_${bid_id}`);
        let $sent_success = $(`#sent_success_${bid_id}`);
        let $sent_error = $(`#sent_error_${bid_id}`);
        let $checkbox = $(this);

        $loading.show();
        $sent_success.hide();
        $sent_error.hide();
        $checkbox.hide();

        $.ajax({
            url: `/bids/${$(this).attr('data-bid-id')}`,
            type: 'PUT',
            data: { bid: { contacts_sent: $(this).is(':checked') } },
            dataType: "json"
        }).success(function () {
            $sent_success.show();
        }).error(function () {
            $sent_error.show();
        }).complete(function() {
            $loading.hide();
            $checkbox.show();
        });
    });
});