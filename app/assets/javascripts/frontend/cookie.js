/**
 * Deletes a cookie by setting its value to an empty string and setting its expiration date to the past.
 *
 * @param {string} name - The name of the cookie to delete.
 */
const deleteCookie = (name) => {
    setCookie(name, "", {
        'max-age': -1
    })
}

/**
 * Sets a cookie with the provided name, value, and options.
 *
 * @param {string} name - The name of the cookie.
 * @param {any} value - The value to be stored in the cookie.
 * @param {object} options - Additional options for the cookie.
 * @param {Date} [options.expires] - The expiration date of the cookie.
 */
const setCookie = (name, value, options = {}) => {
    options = {
        path: '/',
        ...options
    };

    if (options.expires instanceof Date) {
        options.expires = options.expires.toUTCString();
    }

    let updatedCookie = name + "=" + JSON.stringify(value);

    for (let optionKey in options) {
        updatedCookie += "; " + optionKey;
        let optionValue = options[optionKey];
        if (optionValue !== true) {
            updatedCookie += "=" + optionValue;
        }
    }

    document.cookie = updatedCookie;
}

/**
 * Retrieves the value of a cookie with the given name.
 *
 * @param {string} name - The name of the cookie.
 * @return {string|undefined} The value of the cookie, or undefined if the cookie does not exist.
 */
const getCookie = (name) => {
    let matches = document.cookie.match(new RegExp(
        "(?:^|; )" + name.replace(/([\.$?*|{}\(\)\[\]\\\/\+^])/g, "\\$1") + "=([^;]*)"
    ));
    return matches ? decodeURIComponent(matches[1]) : undefined;
}

export {
    setCookie,
    getCookie,
    deleteCookie
}
