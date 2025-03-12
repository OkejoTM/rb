import sortable from 'html5sortable/dist/html5sortable.es.js'

$(document).ready(function(){
    let $sortable = sortable('#property_tags')[0];
    if(!_.isNil($sortable)) {
        $sortable.addEventListener('sortupdate', function(e) {
            let dataIDList = $(this).children().map(function(index) {
                $(this).find( ".position" ).text(index + 1);
                return "property_tag[]=" + $(this).find('td').attr('id');
            }).get().join("&");

            $.ajax({
                url: $(this).data("url"),
                type: "PATCH",
                data: dataIDList,
            });
        });
    }

    sortable('.js-sortable-table', {
        items: "tr.js-sortable-tr",
        placeholder: '<tr><td colspan="9">The row will appear here</td></tr>',
        forcePlaceholderSize: false
    })
});

