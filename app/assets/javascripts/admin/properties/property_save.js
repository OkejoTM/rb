import { noty_success, noty_error } from '../init_noty.js'

function updateTextareaByCkeditorValue(textarea){
    $(textarea).val($(textarea.parentNode).find("[role='textbox']").html())
}

function isModeratedForm(form) {
    let $property_moderated = $(form.parent()).find('#property_moderated').get(0);
    if ($property_moderated != null && $property_moderated != undefined) {
        return $property_moderated.checked;
    }
    return false;
}

// TODO: delete
function get_form_data(form) {
    var formData = new FormData(),
        formParams = form.serializeArray();

    $.each(form.find('input[type="file"]'), function(i, tag) {
        $.each($(tag)[0].files, function(i, file) {
            formData.append(tag.name, file);
        });
    });

    $.each(formParams, function(i, val) {
        formData.append(val.name, val.value);
    });

    return formData;
}

$(window).on('load', function () {
    // $('.save-alert').hide();

    $('.property-save').click(function(e) {
        e.preventDefault();

        $(this).attr("disabled", true);

        var $form = $(this.form);
        $(this.form.elements).each(function(index, elem){
            if(elem.type == "textarea") {
                updateTextareaByCkeditorValue(elem);
            }
        });
        save_property($form);
        // window.scrollTo(0, 0);
    });

    var save_property = function(form) {
        // $('.save-alert').hide();

        var formData = get_form_data(form);

        $.ajax({
            method: "POST",
            url: form.attr("action"),
            data: formData,
            cache: false,
            contentType: false,
            processData: false,
            dataType: "json",
            error: function (jqXHR, exception) {
                let msg = 'Ошибка при сохранении, попробуйте еще раз...';
                // $('.save-alert').css('display', 'block').addClass("alert-danger").removeClass("alert-success").empty().append(msg);
                // $("html, body").animate({scrollTop: 0}, "slow");
                noty_error(msg);
            },
            success: function (data) {
                let msg = "<strong>Success!</strong> Запись обновлена  <a target=\"_blank\" href=\"" + data["url"] + "\" class=\"alert-link\">посмотреть запись</a>."
                // $('.save-alert').css('display', 'block').addClass("alert-success").removeClass("alert-danger").empty().append(msg);
                noty_success(msg);
                if (isModeratedForm(form)) {
                    form.parent().css('display', 'none');
                }
            },
            complete: function() {
                $('.property-save').removeAttr("disabled");
            }
        });
    };
});

export { get_form_data };
export { updateTextareaByCkeditorValue };
