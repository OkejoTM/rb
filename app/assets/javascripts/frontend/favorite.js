import {deleteCookie, getCookie, setCookie} from "./cookie";
import {callMetrika} from "./call_metrika";

/**
 * Changes the state of the favorite cookie based on the given property and element to hide.
 *
 * @param {number} idProperty - The ID of the property.
 * @param {HTMLElement} [elementToHide=null] - The element to hide if the property is removed from the favorite cookie.
 */
const changeStateCookieFavorite = (idProperty, elementToHide = null) => {
    const cookieName = 'favorite';
    const nowDate = new Date();
    const cookieDateEnd = new Date(nowDate.setFullYear(nowDate.getFullYear() + 10)); //expires time cookie

    let favoriteValueArray = getCookie(cookieName);

    //if cookie has been set
    if (favoriteValueArray !== undefined) {
        favoriteValueArray = JSON.parse(favoriteValueArray);
        let indexValue = favoriteValueArray.indexOf(idProperty);

        //if cookie has id, delete id from cookie
        if (indexValue > -1) {
            favoriteValueArray.splice(indexValue, 1);

            //hide element
            if (elementToHide != null)
                elementToHide.style.display = 'none';
        }
        //else add id to cookie
        else {
            favoriteValueArray.unshift(idProperty);
        }
    } //else create cookie
    else {
        favoriteValueArray = [idProperty];
    }

    const count = favoriteValueArray.length;
    if (count > 0) {
        setCookie(cookieName, favoriteValueArray, {expires: cookieDateEnd}); //update cookie
    } else {
        deleteCookie(cookieName); //delete cookie, if empty

        if (window.location.href.includes("favorites")) {
            $("#favorite-not-found").show();
        }
    }

    //update cookie count everywhere
    changeStateFavoriteNavIcon(count);
}

/**
 * Updates the state of the favorite navigation icon based on the given count.
 *
 * @param {number} count - The count of favorites. Defaults to 0 if not provided.
 */
const changeStateFavoriteNavIcon = (count = 0) => {
    const elements = document.querySelectorAll('.favorite-nav');

    if (count > 0) {
        //update favorite count
        const countObjects = document.querySelectorAll('#favorites-count');
        countObjects.forEach(element => element.innerHTML = count);

        //if icon hidden, show
        if (elements[0].style.display === 'none') {
            elements.forEach(element => element.style.display = 'list-item');
        }
    } else {
        //hide icon
        elements.forEach(element => element.style.display = 'none');
    }
}

/**
 * Calls the appropriate Metrika function based on the given callPlace and isLiked parameters.
 *
 * @param {boolean} [isLiked=false] - Indicates whether the item is liked or not. Defaults to false.
 * @param {('card'|'property'|'bookmark list')} [callPlace='card'] - The place where the call is made. Defaults to 'card'.
 * @return {void} This function does not return a value.
 */
const callMetrics = (isLiked = false, callPlace = 'card') => {
    switch (callPlace) {
        case "card":
            if (isLiked) {
                callMetrika('click-add-bookmark-card');
            } else {
                callMetrika('click-remove-bookmark-card');
            }
            break
        case 'property':
            if (isLiked) {
                callMetrika('click-add-bookmark-property');
            } else {
                callMetrika('click-remove-bookmark-property');
            }
            break;
        case 'bookmark list':
            callMetrika('click-remove-bookmark');
            break;
    }
}

/**
 * Initializes the favorite functionality.
 *
 * @param {Event} e - The click event object.
 */
const readyFavorite = function (e) {
    $('.like-icon').add('.delete-favorite').click(function () {
        const id = $(this).data('property_id');
        const elementToHide = $(this).data('element_hide') ? this.parentElement.parentElement : null;
        const place = $(this).data('call_place') ? $(this).data('call_place') : 'card';

        const isLiked = $(this).attr('class').includes('liked');
        //?attr() используется вместо data(), потому что вторая не обновляет DOM-дерево и attr не обновляет результат data
        $(this).children('.tip-content').text($(this).attr('data-tip-content-alt'));
        $(this).attr({
            'data-tip-content': $(this).attr('data-tip-content-alt'),
            'data-tip-content-alt': $(this).attr('data-tip-content'),
        });

        changeStateCookieFavorite(id, elementToHide);
        callMetrics(isLiked, place);
    });
}

$(function (e) {
    readyFavorite(e);

    $(document).on('render_async_load', function (event) {
        readyFavorite(event);
    });
});
