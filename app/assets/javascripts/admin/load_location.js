$(function () {

    function appendSelectValues(obj, selectValues) {
        obj.append($("<option></option>")
            .attr("value", '')
            .text('Все'));

        $.each(selectValues, function(index, elem) {
            obj.append($("<option></option>")
                .attr("value", elem.id)
                .text(elem.title_ru));
        });
        obj.removeAttr('disabled');
    }

    $('.select-continent').change(function() {
        $('.select-country, .select-region, .select-city').find('option').remove();
        $('.select-country, .select-region, .select-city').attr('disabled', 'disabled');

        $.ajax({
            method: "GET",
            url: "/countries",
            data: { continent: $(this).val() },
            dataType: "json"
        }).done(function( selectValues ) {
            appendSelectValues($('.select-country'), selectValues);
        });
    });

    $('.select-country').change(function() {
        $('.select-region, .select-city').find('option').remove();
        $('.select-region, .select-city').attr('disabled', 'disabled');

        $.ajax({
            method: "GET",
            url: "/regions",
            data: { country_id: $(this).val() },
            dataType: "json"
        }).done(function( selectValues ) {
            appendSelectValues($('.select-region'), selectValues);
        });
    });

    $('.select-region').change(function() {
        $('.select-city').find('option').remove();
        $('.select-city').attr('disabled', 'disabled');

        $.ajax({
            method: "GET",
            url: "/cities",
            data: { region_id: $(this).val(),
                continent: $('#country_id option:selected').attr('continent') },
            dataType: "json"
        }).done(function( selectValues ) {
            appendSelectValues($('.select-city'), selectValues);
        });
    });

});