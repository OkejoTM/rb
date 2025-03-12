function mmenuInit() {
    var wi = $(window).width();
    if(wi <= '992') {

        $('#footer').removeClass("sticky-footer");

        $(".mmenu-init" ).remove();
        $("#navigation").clone().addClass("mmenu-init").insertBefore("#navigation").removeAttr('id').removeClass('style-1 style-2').find('ul').removeAttr('id');
        $(".mmenu-init").find(".container").removeClass("container");

        $(".mmenu-init").mmenu({
            "counters": true
        }, {
            // configuration
            offCanvas: {
                pageNodetype: "#wrapper"
            }
        });

        var mmenuAPI = $(".mmenu-init").data( "mmenu" );
        var $icon = $(".hamburger");

        $(".mmenu-trigger").click(function() {
            mmenuAPI.open();
        });

        mmenuAPI.bind( "open:finish", function() {
            setTimeout(function() {
                $icon.addClass( "is-active" );
            });
        });
        mmenuAPI.bind( "close:finish", function() {
            setTimeout(function() {
                $icon.removeClass( "is-active" );
            });
        });


    }
    $(".mm-next").addClass("mm-fullsubopen");
}

export { mmenuInit };