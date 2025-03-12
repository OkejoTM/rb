import { CustomUploadAdapterPlugin } from './ckeditor/upload_adapter_plugin.js'
const editors = new Map();

function ckeditor_create(item) {
    ClassicEditor
        .create( item, {
            toolbar: [ 'heading', '|',
                'bold', 'italic', 'link', 'bulletedList', 'numberedList', 'blockQuote', '|',
                'undo', 'redo'  ]
        } )
        .then( editor => {
            editor.id = item.id;
            editors.set(editor.id, editor);

            console.log( editor );
        } )
        .catch( error => {
            console.error( error );
        } );
}

function image_uploader_ckeditor_create(item) {
    ClassicEditor
        .create( item, {
            extraPlugins: [ CustomUploadAdapterPlugin ],
            toolbar: [ 'heading', '|',
                'bold', 'italic', 'link', 'bulletedList', 'numberedList', 'imageUpload', 'blockQuote', '|',
                'undo', 'redo'  ]
        } )
        .then( editor => {
            console.log( editor );
            console.log( Array.from( editor.ui.componentFactory.names() ) );
        } )
        .catch( error => {
            console.error( error );
        } );
}

function init_array_ckeditors(css_selectors) {
    $(css_selectors).each(function(index) {
        init_ckeditors(css_selectors[index])
    })
}

function init_array_image_uploader_ckeditors(css_selectors) {
    $(css_selectors).each(function(index) {
        init_image_uploader_ckeditors(css_selectors[index])
    })
}

function init_ckeditors(css_selector) {
    if ($(css_selector) != null) {
        var $e = $(css_selector);
        for (var i = 0; i < $e.length; i++) {
            ckeditor_create($e[i]);
        }
    }
}

function init_image_uploader_ckeditors(css_selector) {
    if ($(css_selector) != null) {
        var $e = $(css_selector);
        for (var i = 0; i < $e.length; i++) {
            image_uploader_ckeditor_create($e[i]);
        }
    }
}

export { ckeditor_create,
         image_uploader_ckeditor_create,
         init_array_ckeditors,
         init_array_image_uploader_ckeditors,
         init_ckeditors,
         init_image_uploader_ckeditors,
         editors };
