import {carousel, owlCarousel} from "./custom/carousel";
import {gridLayoutSwitcher} from "./custom/listing_layout_switcher";

$(function () {
    if ($('#country_properties').length > 0) {
        $(document).on('render_async_load', function (event) {
            carousel();
            owlCarousel();
            gridLayoutSwitcher();
        });
    }
});
