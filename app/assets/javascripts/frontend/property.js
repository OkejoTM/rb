import { callMetrika } from './call_metrika.js'

$(function () {
  $('#print-pdf-id').click(function () {
    let pdf_link = $(this).data('pdf-link');

    callMetrika('submit-print-pdf-btn');

    window.open(pdf_link);
    });

    //Метрика для отслеживания переходов на страницу с неактивной недвижимостью
    if ($('#disabled-property').length) {
        callMetrika('disabled-property');
    }

    //Метрика нажатий кнопки "Показать на карте"
    $('#show_map').click(function () {
        callMetrika('submit-properties-map-btn');
    });

    //Метрика нажатий кнопки "Больше условий"
    $('#country-more-options').click(function () {
        callMetrika('submit-country-more-options-btn');
    });
});
