import {carousel, owlCarousel} from "./custom/carousel";

$(function () {
    if ($('#best_deals').length > 0) {
        $(document).on('render_async_load', function (event) {
            carousel();
            owlCarousel();
        });
    }
});
