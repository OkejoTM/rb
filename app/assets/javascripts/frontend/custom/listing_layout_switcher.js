/*----------------------------------------------------*/
/*  Listing Layout Switcher
/*----------------------------------------------------*/
function gridLayoutSwitcher() {

    var listingsContainer = $('.listings-container');
    let $propertiesContainer = $('#properties_list');


    if(window.location.search.indexOf("map=on") !== -1) {
      toggleMap(true);
    } else {
      // switcher buttons / anchors
      if ( $(listingsContainer).is(".list-layout") ) {
        owlReload();
        $('.layout-switcher a.grid, .layout-switcher a.grid-three').removeClass("active");
        $('.layout-switcher a.list').addClass("active");
      }

      if ( $(listingsContainer).is(".grid-layout") ) {
        owlReload();
        $('.layout-switcher a.grid').addClass("active");
        $('.layout-switcher a.grid-three, .layout-switcher a.list').removeClass("active");
        gridClear(2);
      }

      if ( $(listingsContainer).is(".grid-layout-three") ) {
        owlReload();
        $('.layout-switcher a.grid, .layout-switcher a.list').removeClass("active");
        $('.layout-switcher a.grid-three').addClass("active");
        gridClear(3);
      }
    }


    // grid cleaning
    function gridClear(gridColumns) {
        $(listingsContainer).find(".clearfix").remove();
        $(".listings-container > .listing-item:nth-child("+gridColumns+"n)").after("<div class='clearfix'></div>");
    }


    // objects that need to resized
    var resizeObjects =  $('.listings-container .listing-img-container img, .listings-container .listing-img-container');

    // if list layout is active
    function listLayout() {
      if (!$('.layout-switcher a').is(".list.active")) { return; }

      toggleMap(false);

      $(listingsContainer).each(function(){
        $(this).removeClass("grid-layout grid-layout-three");
        $(this).addClass("list-layout");
      });

      $('.listing-item').each(function(){
        let listingContent = $(this).find('.listing-content').height();
        $(this).find(resizeObjects).css('height', ''+listingContent+'');
      });
    }
    listLayout();

    $(window).on('load resize', function() {
        $(resizeObjects).css('height', '0');
        listLayout();
        // owlReload();
        // agencyLayout();
    });


    // if grid layout is active
    $('.layout-switcher a.grid').on('click', function(e) {
      gridClear(2);
    });

    function gridLayout() {
      if(!$('.layout-switcher a').is(".grid.active")) { return; }

      toggleMap(false);

      // Стили под плиточки
      $(listingsContainer).each(function(){
        $(this).removeClass("list-layout grid-layout-three");
        $(this).addClass("grid-layout");
      });

      // Ставим все картинки автоматически
      $('.listing-item').each(function(){
        $(this).find(resizeObjects).css('height', 'auto');
      });

      // Выравниваем плиточки по строкам
      $('.listing-item').each(function(){
        // Если справа тоже плиточка
        if ($(this).next().length > 0 && $(this).next().get(0).className == "listing-item") {
          //Собираем высоты плиточек в строке
          let height_all = [$(this).height(), $(this).next().height()];
          //Находим минимальную высоту плиточки
          let min_h = Math.min.apply(Math, height_all);
          //Выравниваем высоты остальных плиточек по минимальной
          $(this).find('img').css('height', min_h - $(this).find('.listing-content').height());
          $(this).next().find('img').css('height', min_h - $(this).next().find('.listing-content').height());
        }
      });


    }
    gridLayout();


    // if grid layout is active
    $('.layout-switcher a.grid-three').on('click', function(e) {
      gridClear(3);
    });

    function gridThreeLayout() {
      if(!$('.layout-switcher a').is(".grid-three.active")) { return }

      toggleMap(false);

      $(listingsContainer).each(function(){
        $(this).removeClass("list-layout grid-layout");
        $(this).addClass("grid-layout-three");
      });

      $('.listing-item').each(function(){
        $(this).find(resizeObjects).css('height', 'auto');
      });

    }
    gridThreeLayout();


    // Mobile fixes
    $(window).on('resize', function() {
        $(resizeObjects).css('height', '0');
        listLayout();
        gridLayout();
        gridThreeLayout();
    });

    $(window).on('load resize', function() {
        var winWidth = $(window).width();

        if(winWidth < 992) {
            owlReload();

            // reset to two columns grid
            gridClear(2);
        }

        if(winWidth > 992) {
            if ( $(listingsContainer).is(".grid-layout-three") ) {
                gridClear(3);
            }
            if ( $(listingsContainer).is(".grid-layout") ) {
                gridClear(2);
            }
        }

        if(winWidth < 768) {
            if ( $(listingsContainer).is(".list-layout") ) {
                $('.listing-item').each(function(){
                    $(this).find(resizeObjects).css('height', 'auto');
                });
            }
        }

        if(winWidth < 1366) {
            if ( $(".fs-listings").is(".list-layout") ) {
                $('.listing-item').each(function(){
                    $(this).find(resizeObjects).css('height', 'auto');
                });
            }
        }
    });


    // owlCarousel reload
    function owlReload() {
        $('.listing-carousel').each(function(){
            $(this).data('owlCarousel').reload();
        });

        //Карусель на главной
        if ($('.property-main-carousel').length > 0){
        // if ($('.layout-switcher a').length == 0){

            $('.listing-item').each(function(){
                $(this).find(resizeObjects).css('height', "auto");
            });

            //Выравниваем высоты по минимальной
            // $('.carousel.owl-carousel.owl-theme').each(function() {
            //     var height_all = $(this).find('.listing-item').map(function() {
            //         return $(this).height();
            //     });
            //
            //     var min_h = Math.min.apply(Math, height_all);
            //
            //     $(this).find('.listing-item').map(function() {
            //         $(this).find('img').css('height', min_h - $(this).find('.listing-content').height())
            //     });
            // })
        }
    }

    // function agencyLayout(){
    //     //Выравниваем высоты для картинок агентств
    //     $('.agency-item').each(function(){
    //         var listingContent = $(this).find('.agent-content').height();
    //         $(this).find('img').css('height', ''+listingContent+'');
    //     });
    // }

    // @param [Boolean] value true - показать, false - спрятать
    function toggleMap(value) {
      $('.sort-by').toggle(!value);
      $propertiesContainer.toggle(!value);
      $('#map-tab').toggle(value);
      $('#show_map').toggle(!value);
      if(!value) {
        window.history.replaceState({}, '', _.replace(window.location.href, new RegExp(/(?:\?|\&)map=on/), ''));
      } else {
        $('.layout-switcher a').removeClass('active');
      }
    }

    $('#show_map').on('click', function(e) {
      $propertiesContainer.hide();
      toggleMap(true);
    });

    // switcher buttons
    $('.layout-switcher a').on('click', function(e) {
        e.preventDefault();

        var switcherButton = $(this);
        switcherButton.addClass("active").siblings().removeClass('active');

        if(!$('.layout-switcher a').is(".map.active")) {
          owlReload();
          // reset images height
          $(resizeObjects).css('height', 'unset');
        }

        // if grid layout is active
        gridLayout();

        // if three columns grid layout is active
        gridThreeLayout();

        // if list layout is active
        listLayout();

        // if map layout is active
        // mapLayout();

    });

}
gridLayoutSwitcher();

export { gridLayoutSwitcher };
