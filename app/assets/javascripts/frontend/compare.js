import {deleteCookie, getCookie, setCookie} from "./cookie";
import {callMetrika} from "./call_metrika";

const COMPARE_URL = 'compare_properties';
const COMPARE_TAG = 'liked';
const COOKIE_NAME = 'compare';

/**
 * Changes the state of the compare cookie based on the given property and element to hide.
 *
 * @param {Object} property - The property object to add or remove from the compare cookie.
 * @param {number} property.id - The ID of the property.
 * @param {HTMLElement} [elementToHide=null] - The element to hide if the property is removed from the compare cookie.
 */
const changeStateCookieCompare = (property, elementToHide = null) => {
    const nowDate = new Date();
    const cookieDateEnd = new Date(nowDate.setFullYear(nowDate.getFullYear() + 10)); //expires time cookie

    let compareValueArray = getCookie(COOKIE_NAME);

    //if cookie has been set
    if (compareValueArray !== undefined) {
        compareValueArray = JSON.parse(compareValueArray);
        const indexValue = compareValueArray.indexOf(property.id);

        //if cookie has id, delete id from cookie
        if (indexValue > -1) {
            compareValueArray.splice(indexValue, 1);
            deletePropertyFromCompareList(property.id);

            //hide element
            if (elementToHide != null)
                elementToHide.style.display = 'none';
        }
        //else add id to cookie
        else {
            if (compareValueArray.length === 100) {
                changeStateCookieCompare({id: compareValueArray[0]}, elementToHide);
            }

            compareValueArray.unshift(property.id);
            addPropertyToCompareList(property);
        }
    } //else create cookie
    else {
        compareValueArray = [property.id];
        addPropertyToCompareList(property);
        hideShowButtons(false);
    }

    const count = compareValueArray.length;
    const compareButton = document.querySelector(".csm-trigger");

    if (count > 0) {
        setCookie(COOKIE_NAME, compareValueArray, {expires: cookieDateEnd}); //update cookie
        compareButton.style.display === "none" ? compareButton.style.display = "block" : null;
    } else {
        deleteCookie(COOKIE_NAME); //delete cookie, if empty
        hideShowButtons(true);
    }

    //update cookie count everywhere
    //changeStateFavoriteNavIcon(count);
}

/**
 * Adds a property to the compare list.
 *
 * @param {Object} property - The property object to be added to the compare list.
 * @param {number} property.id - The ID of the property.
 * @param {string} property.seo_path - The SEO path of the property.
 * @param {string} property.sale_type - The sale type of the property.
 * @param {string} property.title - The title of the property.
 * @param {string} property.price - The price of the property.
 * @param {string} property.img_path - The image path of the property.
 */
const addPropertyToCompareList = (property) => {
    const property_element = /* html */`
        <div class="listing-item compact" id="property_compare_compact${property.id}">
            <a href="${property.seo_path}" class="listing-img-container">
                <div class="remove-from-compare" id="remove-compare-${property.id}" data-property_id="${property.id}">
                    <i class="fas fa-times"></i>
                </div>
                <div class="listing-badges">
                    <span>${property.sale_type}</span>
                </div>
                <div class="listing-img-content">
                    <span class="listing-compact-title">${property.title} <i>${property.price}</i></span>
                </div>
                <img src="${property.img_path}" alt="">
            </a>
        </div>`
    const property_list = document.querySelector('.csm-properties');
    property_list.innerHTML = property_element + property_list.innerHTML;
    $(`#remove-compare-${property.id}`).click(function (e) {
        removeFromCompareEventListener(this, e);
    });
}

/**
 * Deletes a property from the compare list based on the given ID.
 *
 * @param {number} id - The ID of the property to be deleted.
 */
const deletePropertyFromCompareList = (id) => {
    document.getElementById(`property_compare_compact${id}`).remove();
}

/**
 * Calls the appropriate Metrika function based on the given callPlace and isLiked parameters.
 *
 * @param {('card'|'property'|'compare list page'|'<')} [callPlace='card'] - The place where the call is made. Defaults to 'card'.
 * @param {boolean} [isLiked=false] - Indicates whether the item is liked or not. Defaults to false.
 */
const callMetrics = (callPlace = 'card', isLiked = false) => {
    switch (callPlace) {
        case "card":
            if (isLiked) {
                callMetrika('click-add-compare-card');
            } else {
                callMetrika('click-remove-compare-card');
            }
            break
        case 'property':
            if (isLiked) {
                callMetrika('click-add-compare-property');
            } else {
                callMetrika('click-remove-compare-property');
            }
            break;
        case 'compare list page':
            callMetrika('click-remove-compare');
            break;
        case '<':
            callMetrika('click-show-compare');
            break;
    }
}

/**
 * Function on switching between compare types in compare page.
 */
const switchCompareType = () => {
    const active = 'active';
    const $residentialBtn = $('#residential-switch-button');
    const residentialBody = document.getElementById('residential-body');
    const isResBody = residentialBody ? true : false;
    const $commercialBtn = $('#commercial-switch-button');
    const commercialBody = document.getElementById('commercial-body');
    const isCommBody = commercialBody ? true : false;
    const $landBtn = $('#land-switch-button');
    const landBody = document.getElementById('land-body');
    const isLandBody = landBody ? true : false;
    const $removeBtn = $('span.remove-from-compare');

    $removeBtn.click(function (e) {
        e.preventDefault();
        const num = $(this).data('num');
        const type = $(this).data('type');
        const compareListItems = $(`.compare-list-item-${num}.${type}`)
        compareListItems.hide();

        let isAllHidden = true;
        for (const el of compareListItems[1].parentElement.children) {
            if ($(el).hasClass(type) && $(el).css('display') !== 'none') {
                isAllHidden = false;
                break;
            }
        }

        if (isAllHidden) {
            const nothingFound = $('#compare-list-nothing-found').clone();
            nothingFound.css('display', 'block');
            $(`#${type}-body`).empty().append(nothingFound)
        }
    });

    $residentialBtn.click(function () {
        $residentialBtn.addClass(active);
        if (isResBody) residentialBody.style.display = 'block';

        $commercialBtn.removeClass(active);
        if (isCommBody) commercialBody.style.display = 'none';

        $landBtn.removeClass(active);
        if (isLandBody) landBody.style.display = 'none';
    });

    $commercialBtn.click(function () {
        $residentialBtn.removeClass(active);
        if (isResBody) residentialBody.style.display = 'none';

        $commercialBtn.addClass(active);
        if (isCommBody) commercialBody.style.display = 'block';

        $landBtn.removeClass(active);
        if (isLandBody) landBody.style.display = 'none';
    });

    $landBtn.click(function () {
        $residentialBtn.removeClass(active);
        if (isResBody) residentialBody.style.display = 'none';

        $commercialBtn.removeClass(active);
        if (isCommBody) commercialBody.style.display = 'none';

        $landBtn.addClass(active);
        if (isLandBody) landBody.style.display = 'block';
    });
}

/**
 * Initializes the compare functionality.
 */
const readyCompare = function () {
    $('.compare-button').click(function () {
        const thisEl = $(this)
        if (!thisEl.hasClass('widget-button')) thisEl.toggleClass(COMPARE_TAG);
        const property = {
            id: thisEl.data('property_id'),
            title: thisEl.data('property_title'),
            seo_path: thisEl.data('seo_path'),
            img_path: thisEl.data('img_path'),
            sale_type: thisEl.data('sale_type'),
            price: thisEl.data('price'),
        }
        const elementToHide = thisEl.data('element_hide') ? this.parentElement.parentElement : null;
        const isTagged = thisEl.hasClass(COMPARE_TAG);

        changeTipText(thisEl);
        const changeChild = thisEl.data('change_child');
        if (changeChild) {
            (isTagged) ?
                thisEl.children(`:${changeChild}`).css("background-image", `url(${thisEl.data('compare_image_alt')})`) :
                thisEl.children(`:${changeChild}`).css("background-image", `url(${thisEl.data('compare_image')})`);
        } else {
            (isTagged) ?
                thisEl.css("background-image", `url(${thisEl.data('compare_image_alt')})`) :
                thisEl.css("background-image", `url(${thisEl.data('compare_image')})`);
        }

        changeStateCookieCompare(property, elementToHide);
        callMetrics(thisEl.data('call_place'), isTagged);
    });

    if (window.location.href.includes(COMPARE_URL)) {
        switchCompareType();
    }
}

/**
 * Hides or shows buttons based on the value.
 *
 * @param {boolean} to_hide - Indicates whether to hide the buttons or not.
 */
const hideShowButtons = (to_hide = false) => {
    const buttons = document.getElementById('compare-right-side-buttons');
    const nothingFound = document.getElementById('compare-right-side-nothing-found');

    if (to_hide) {
        buttons.style.display = "none";
        nothingFound.style.display = "block";
    } else {
        buttons.style.display = "block";
        nothingFound.style.display = "none";
    }
}

/**
 * Sets the default compare icon for the specified element ID.
 *
 * @param {number | string} id - The ID of the element to set the default icon for.
 */
const setDefaultCompareIcon = (id) => {
    const $tmpBtn = $("#compare-button-" + id);
    if ($tmpBtn) {
        const changeChild = $tmpBtn.data('change_child');
        changeChild ? $tmpBtn.children(`:${changeChild}`).css("background-image", `url(${$tmpBtn.data('compare_image')})`) :
            $tmpBtn.css("background-image", `url(${$tmpBtn.data('compare_image')})`);
        $tmpBtn.removeClass(COMPARE_TAG);
        changeTipText($tmpBtn);
    }
}

/**
 * Updates the tip content of the specified element based on the 'data-tip-content-alt' attribute.
 *
 * @param {JQuery} el - The element to update the tip content for.
 */
const changeTipText = (el) => {
    //?attr() используется вместо data(), потому что вторая не обновляет DOM-дерево и attr не обновляет результат data
    el.children('.tip-content').text(el.attr('data-tip-content-alt'));
    el.attr({
        'data-tip-content': el.attr('data-tip-content-alt'),
        'data-tip-content-alt': el.attr('data-tip-content'),
    });
}

/**
 * Function on click '.remove-from-compare' button.
 *
 * @param {HTMLElement} el - The element representing the item to be removed.
 * @param {Event} e - The click event.
 */
const removeFromCompareEventListener = (el, e) => {
    e.preventDefault();
    const id = $(el).data('property_id');
    changeStateCookieCompare({id: id});
    setDefaultCompareIcon(id);
    callMetrics($(el).data('call_place'), false);
}

$(function () {
    const compareValueArray = getCookie(COOKIE_NAME);

    if (!compareValueArray || !compareValueArray.length) {
        document.querySelector(".csm-trigger").style.display = "none";
    }

    readyCompare();

    $('.remove-from-compare').click(function (e) {
        removeFromCompareEventListener(this, e);
    });

    $('#compare-reset-button').click(function (e) {
        e.preventDefault();
        JSON.parse(getCookie(COOKIE_NAME)).forEach((id) => {
            setDefaultCompareIcon(id);
        });
        deleteCookie(COOKIE_NAME);
        document.querySelector('.csm-properties').replaceChildren(...[]);
        hideShowButtons(true);
    });

    $('.csm-trigger').click(function () {
        callMetrics('<');
    });

    $(document).on('render_async_load', function (event) {
        readyCompare();
    });
});
