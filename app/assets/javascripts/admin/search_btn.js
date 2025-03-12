$(function () {
    if ($('#search_btn').length > 0) {
        $(document).keyup(function (event) {
            // по нажатию Enter
            if (event.keyCode === 13) {
                $('#search_btn').click();
            }
        });
    }
});