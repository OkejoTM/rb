import 'select2';                       // globally assign select2 fn to $ element

$(function () {
    $('.select2-enable').select2({
        language: 'ru',
        theme: "bootstrap"
    });

    $('.select2-multiple').select2({
        language: 'ru',
        theme: "bootstrap",
        multiple: "multiple"
    });
});