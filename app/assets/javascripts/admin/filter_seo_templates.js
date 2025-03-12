$(function () {
    function appendSelectValues(obj, selectValues) {
        if (selectValues.length > 1) {
            obj.append($("<option></option>")
                .attr("value", "")
                .text('Все'));

            $.each(selectValues, function (index, elem) {
                appendSelectValue(obj, elem);
            });
        } else if (selectValues.length == 1) {
            appendSelectValue(obj, selectValues[0]);
        }
    }

    function appendSelectValue(obj, selectValue) {
        obj.append($("<option></option>")
            .attr("value", selectValue.id)
            .text(selectValue.title_ru));
    }

    function requestPropertyTypes(property_type_group_id) {
        $.ajax({
            method: "GET",
            url: "/property_types",
            data: {property_type_group_id: property_type_group_id},
            dataType: "json"
        }).done(function (selectValues) {
            appendSelectValues($('.select-property-type'), selectValues);
            $('.select-property-type').removeAttr('disabled');
        });
    }


    $('.select-property-type-group').change(function() {
        $('.select-property-type').find('option').remove();
        $('.select-property-type').attr('disabled', 'disabled');

        if ($(this).val() != '' && $(this).val() != undefined) {
            requestPropertyTypes($(this).val());
        }
    });

    $('.select-property-supertype').change(function() {
        $('.select-property-type-group').find('option').remove();
        $('.select-property-type-group').attr('disabled', 'disabled');

        $('.select-property-type').find('option').remove();
        $('.select-property-type').attr('disabled', 'disabled');

        if ($(this).val() != '' && $(this).val() != undefined) {
            $.ajax({
                method: "GET",
                url: "/property_type_groups",
                data: {property_supertype_id: $(this).val()},
                dataType: "json"
            }).done(function (selectValues) {
                if (selectValues.length > 1) {
                    appendSelectValues($('.select-property-type-group'), selectValues);
                    $('.select-property-type-group').removeAttr('disabled');
                } else if (selectValues.length == 1) {
                    appendSelectValue($('.select-property-type-group'), selectValues[0]);
                    $('.select-property-type-group').removeAttr('disabled');

                    requestPropertyTypes(selectValues[0].id);
                }
            });
        }
    });
});