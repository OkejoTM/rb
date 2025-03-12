import { init_array_ckeditors, init_array_image_uploader_ckeditors } from './init_ckeditor.js'

$(function () {
    init_array_ckeditors(['textarea[class*="classic_ckeditor"]']);
    init_array_image_uploader_ckeditors(['textarea[class*="image_uploader_ckeditor"]']);
});
