/*----------------------------------------------------*/
/*  Search Type Buttons
/*----------------------------------------------------*/
function searchTypeButtons() {

    // Radio attr reset
    $('.search-type label.active input[type="radio"]').prop('checked',true);

    // Positioning indicator arrow
    var buttonWidth = $('.search-type label.active').width();
    var arrowDist = $('.search-type label.active').position().left;
    $('.search-type-arrow').css('left', arrowDist + (buttonWidth/2) );

    $('.search-type label').on('change', function() {
        $('.search-type input[type="radio"]').parent('label').removeClass('active');
        $('.search-type input[type="radio"]:checked').parent('label').addClass('active');

        // Positioning indicator arrow
        var buttonWidth = $('.search-type label.active').width();
        var arrowDist = $('.search-type label.active').position().left;

        $('.search-type-arrow').css({
            'left': arrowDist + (buttonWidth/2),
            'transition':'left 0.4s cubic-bezier(.87,-.41,.19,1.44)'
        });
    });

}

export { searchTypeButtons };