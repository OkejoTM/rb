import 'gmaps';
import 'bootstrap/dist/js/bootstrap';
import 'sticky-kit/dist/sticky-kit.js';
import 'magnific-popup';
require("waypoints/lib/jquery.waypoints.js");

// make Masonry a jQuery plugin
jQueryBridget( 'masonry', Masonry, $ );
import Backend from 'i18next-xhr-backend';
import LanguageDetector from 'i18next-browser-languagedetector';

var readyChangeLng;
i18next
    .use(Backend)
    .use(LanguageDetector)
    .init({
        lng: 'en',
        fallbackLng: ['en', 'ru'],
        backend: {
            loadPath: '/locales/{{lng}}_{{ns}}.json'
        }
    }, function(err, t) {
        if (err)
            return console.log('something went wrong loading', err);
    });


var req = require.context("findeo/scripts/", true, /^(.*\.(js\.*)[^.]*$)/)
req.keys().forEach(function(key){
    req(key);
});



