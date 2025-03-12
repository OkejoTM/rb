function setSliderValues(slider, firstValue, secondValue) {
    slider.children( ".first-slider-value" ).val( firstValue );
    slider.children( ".second-slider-value" ).val( secondValue );
};

// Area Range
function formatArea(dataUnit, area) {
    return area  + " " + dataUnit;
};

// Price Range
function formatPrice(dataUnit, price) {
    return dataUnit  + price.toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,");
};/*----------------------------------------------------*/
/*  Range Sliders
/*----------------------------------------------------*/

function sliders() {

    $("#area-range").each(function () {

        var dataMin = $(this).attr('data-min');
        var dataMax = $(this).attr('data-max');
        var dataUnit = $(this).attr('data-unit');

        $(this).append("<input type='text' class='first-slider-value'disabled/><input type='text' class='second-slider-value' disabled/>");

        $(this).slider({

            range: true,
            min: dataMin,
            max: dataMax,
            step: 100,
            values: [dataMin, dataMax],

            slide: function (event, ui) {
                event = event;
                setSliderValues($(this), formatArea(dataUnit, ui.values[0]), formatArea(dataUnit, ui.values[1]));
            }
        });
        setSliderValues($(this), formatArea(dataUnit, $(this).slider("values", 0)), formatArea(dataUnit, $(this).slider("values", 1)));

    });

    $("#price-range").each(function () {

        var dataMin = $(this).attr('data-min');
        var dataMax = $(this).attr('data-max');
        var dataUnit = $(this).attr('data-unit');

        $(this).append("<input type='text' class='first-slider-value' disabled/><input type='text' class='second-slider-value' disabled/>");


        $(this).slider({

            range: true,
            min: dataMin,
            max: dataMax,
            step: 1000,
            values: [dataMin, dataMax],

            slide: function (event, ui) {
                event = event;
                $(this).children(".first-slider-value").val(formatPrice(dataUnit, ui.values[0]));
                $(this).children(".second-slider-value").val(formatPrice(dataUnit, ui.values[1]));
            }
        });
        $(this).children(".first-slider-value").val(formatPrice(dataUnit, $(this).slider("values", 0)));
        $(this).children(".second-slider-value").val(formatPrice(dataUnit, $(this).slider("values", 1)));

    });
}

export { sliders };