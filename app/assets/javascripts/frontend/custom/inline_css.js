/*----------------------------------------------------*/
/*  Inline CSS replacement for backgrounds etc.
/*----------------------------------------------------*/
function inlineCSS() {

    // Common Inline CSS
    $(".some-classes, section.fullwidth, .img-box-background, .flip-banner, .property-slider .item, .fullwidth-property-slider .item, .fullwidth-home-slider .item, .address-container").each(function() {
        var attrImageBG = $(this).attr('data-background-image');
        var attrColorBG = $(this).attr('data-background-color');

        if(attrImageBG !== undefined) {
            $(this).css('background-image', 'url('+attrImageBG+')');
        }

        if(attrColorBG !== undefined) {
            $(this).css('background', ''+attrColorBG+'');
        }
    });

}

function parallaxBG() {

    $('.parallax').prepend('<div class="parallax-overlay"></div>');

    $( ".parallax").each(function() {
        var attrImage = $(this).attr('data-background');
        var attrColor = $(this).attr('data-color');
        var attrOpacity = $(this).attr('data-color-opacity');

        if(attrImage !== undefined) {
            $(this).css('background-image', 'url('+attrImage+')');
        }

        if(attrColor !== undefined) {
            $(this).find(".parallax-overlay").css('background-color', ''+attrColor+'');
        }

        if(attrOpacity !== undefined) {
            $(this).find(".parallax-overlay").css('opacity', ''+attrOpacity+'');
        }

    });
}

export { inlineCSS,
         parallaxBG };