import { get_form_data } from './properties/property_save.js'

$(window).on('load', function () {
    $('.translation-save').click(function(e) {
        e.preventDefault();
        let $form = $(this.form);
        save_location($form, $(this));
    });

    var save_location = function(form, btn) {
        var formData = get_form_data(form);

        btn.siblings('#load_process').show();
        btn.siblings('#load_success').hide();
        btn.siblings('#load_error').hide();

        $.ajax({
            method: "POST",
            url: form.attr("action"),
            data: formData,
            cache: false,
            contentType: false,
            processData: false,
            dataType: "json",
            success: function (data) {
                btn.siblings('#load_success').show();
            },
            error: function (jqXHR, exception) {
                btn.siblings('#load_error').show();
            },
            complete: function() {
                btn.siblings('#load_process').hide();
            }
        });
    };
});