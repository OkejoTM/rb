import { carousel, owlCarousel } from './custom/carousel.js'
import { gridLayoutSwitcher } from './custom/listing_layout_switcher.js'
import { callMetrika } from "./call_metrika";

$(function () {
    let $find_btn = $('#find_btn');

    if ($find_btn.length > 0) {
        $find_btn.click(function(e) {
            $('#page').val(0);
            update_properties_list();
        });

        $(document).keyup(function (event) {
            // Фильтрация недвижимости по нажатию Enter
            if (event.keyCode === 13 && !$('#properties_list').hasClass('loading')) {
                $('#page').val(0);
                update_properties_list();
            }
        });

        let $find_sticky = $('#find_sticky');
        let $feedback = $('#client-feedback-modal-btn');
        let $properties_form_height = $('#properties_form').height();

        function updateFindPositionBtn() {
            let $current_window_bottom = $(window).scrollTop() + $(window).height();
            let $properties_form_bottom = $properties_form_height + $('#properties_form').offset().top;

            if ($current_window_bottom < $properties_form_bottom) {
                $feedback.hide();
                $find_sticky.addClass('find_sticky');
                $find_sticky.css('width', $find_sticky.parent().width());
            } else {
                $feedback.show();
                $find_sticky.removeClass('find_sticky');
            }
        }

        $(window).scroll(updateFindPositionBtn);
        updateFindPositionBtn();
    }



    $('#sort_by').on('change', function(evt, params) {
        $('#page').val(0);
        update_properties_list();
    });

    function getMapStatus () {
        if ($('.modal-map').css('display') == "block") {
            return "map=on";
        }
        return "";
    }

    function updateMapStatus(data, mapStatus=getMapStatus()) {
        var resultData = data.replace("&map=on", "").replace("?map=on", "");
        if (mapStatus == "" || mapStatus == null) {
            return resultData;
        }

        if (resultData.indexOf("?") != -1) {
            return resultData + "&" + mapStatus
        } else {
            return resultData + "?" + mapStatus
        }
    }

    function update_properties_list() {
        // $('#properties_load').css('display', 'block');
        // $('#properties_list').empty();

        $('#properties_list').addClass('loading');
        $find_btn.attr({ "disabled" : "disabled" });

        let req_props = $.merge($('#properties_form').serializeArray(),
            [{ name: 'sort_by_price', value: $('#sort_by').val() }]);

        $.ajax({
            method: "GET",
            url: `/${PROPIMO_LOCALE}/properties_list`,
            data: req_props,
            dataType: "json"
        }).done(function (data) {
            // $('#properties_load').css('display', 'none');

            $('#properties_list').removeClass('loading').empty().append(data['partial']);

            $('#breadcrumbs').empty().append(data['breadcrumbs']);

            document.title = data['title'];
            $('#property-body h1').empty().append(data['h1']);

            window.history.replaceState({}, "", updateMapStatus(data['url']));

            if (data['is_need_add_req']) {
                $('#additional-modal-content').css('display', 'block');
            }

            jQuery.each(data['alternative_urls'], function (key, value) {
                $("#locale_" + key).attr('href', value);
            });

            pagination_handler();
            carousel();
            owlCarousel();
            gridLayoutSwitcher();

            $find_btn.removeAttr("disabled");
        });
    }

    function pagination_handler() {
        $("#properties_list div .pagination ul li a, #properties_list div .pagination-next-prev ul li a").click(function () {
            $('#page').val($(this).attr('page'));

            update_properties_list();

            return false;
        });
    }

    pagination_handler();


    function numberWithSpaces(x) {
        return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, " ");
    }

    $('.formatted_number').each(function (index, value) {
        let blacklist_regex = /\D/g;

        let $elem = $(value);
        $elem.val(
            numberWithSpaces($elem.val().replace(blacklist_regex, ''))
        );

        $elem.keyup(function(){
            $(this).val(
                numberWithSpaces($(this).val().replace(blacklist_regex, ''))
            );
        });
    });

    $('#sort_by').chosen().bind('chosen:showing_dropdown', function(){
        callMetrika('click-properties-sort-btn');
    });

    $('#currency').chosen().bind('chosen:showing_dropdown', function(){
        callMetrika('click-properties-choose-currency');
    });
});
