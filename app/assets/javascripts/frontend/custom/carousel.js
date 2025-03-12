/*----------------------------------------------------*/
/*  Slick Carousel
/*----------------------------------------------------*/
function carousel() {

    $('.property-slider').slick({
        slidesToShow: 1,
        slidesToScroll: 1,
        arrows: true,
        fade: true,
        asNavFor: '.property-slider-nav',
        centerMode: true,
        slide: ".item"
    });

    $('.property-slider-nav').slick({
        slidesToShow: 6,
        slidesToScroll: 1,
        asNavFor: '.property-slider',
        dots: false,
        arrows: false,
        centerMode: false,
        focusOnSelect: true,
        responsive: [
            {
                breakpoint: 993,
                settings: {
                    slidesToShow: 4,
                }
            },
            {
                breakpoint: 767,
                settings: {
                    slidesToShow: 3,
                }
            }
        ]
    });


    $('.fullwidth-property-slider').slick({
        centerMode: true,
        centerPadding: '20%',
        slidesToShow: 1,
        responsive: [
            {
                breakpoint: 1367,
                settings: {
                    centerPadding: '15%'
                }
            },
            {
                breakpoint: 993,
                settings: {
                    centerPadding: '0'
                }
            }
        ]
    });


    $('.fullwidth-home-slider').slick({
        centerMode: true,
        centerPadding: '0',
        slidesToShow: 1,
        responsive: [
            {
                breakpoint: 1367,
                settings: {
                    centerPadding: '0'
                }
            },
            {
                breakpoint: 993,
                settings: {
                    centerPadding: '0'
                }
            }
        ]
    });
    $(window).on('load resize', function() {

        // Слайдер с картинками на странице просмотра недвижимости
        $('.property-slider-nav.slick-initialized.slick-slider').each(function () {
            // Находим все высоты для картинок у слайдера
            var height_all = $(this).find('img').map(function () {
                if ($(this).height() > 0) {
                    return $(this).height();
                }
            });

            // Минимальная из найденных высот
            var min_h = Math.min.apply(Math, height_all);

            // Проставляем всем картинкам в sidebar минимальную высоту
            $(this).find('img').css('height', min_h)
            $(this).find('img').css('object-fit', 'contain')
            $(this).find('img').css('width', "100%")
        });
    })
}

/*----------------------------------------------------*/
/*  Owl Carousel
/*----------------------------------------------------*/
function owlCarousel() {

    $('.carousel').owlCarousel({
        autoPlay: false,
        navigation: true,
        slideSpeed: 600,
        items: 3,
        itemsDesktop: [1239, 3],
        itemsTablet: [991, 2],
        itemsMobile: [767, 1]
    });


    $('.logo-carousel').owlCarousel({
        autoPlay: false,
        navigation: true,
        slideSpeed: 600,
        items: 5,
        itemsDesktop: [1239, 4],
        itemsTablet: [991, 3],
        itemsMobile: [767, 1]
    });


    $('.listing-carousel').owlCarousel({
        autoPlay: false,
        navigation: true,
        slideSpeed: 800,
        items: 1,
        itemsDesktop: [1239, 1],
        itemsTablet: [991, 1],
        itemsMobile: [767, 1]
    });

    $('.owl-next, .owl-prev').on("click", function (e) {
        e.preventDefault();
    });

}

export { carousel,
         owlCarousel };