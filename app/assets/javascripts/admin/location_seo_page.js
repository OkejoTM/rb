import { init_array_ckeditors } from './init_ckeditor.js'

$(function () {
    $('#area_fields_modal').on('shown.bs.modal', function (e) {
        init_array_ckeditors(['textarea[class*="classic_ckeditor"]']);
    });
});
