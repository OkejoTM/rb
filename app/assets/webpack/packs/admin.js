// import {} from 'jquery-ujs';
import Rails from '@rails/ujs';
import 'bootstrap/dist/js/bootstrap';
import 'javascripts/metronic';
import 'javascripts/cable';
import 'moment';
import 'bootstrap-datepicker-webpack/dist/js/bootstrap-datepicker.js';
import 'bootstrap-datepicker-webpack/js/locales/bootstrap-datepicker.ru.js';
import 'magnific-popup';
import 'vue/dist/vue.js';
import 'noty';

let req = require.context("javascripts/admin/", true, /^(.*\.(js\.*))[^.]*$/);
req.keys().forEach(function(key){
    req(key);
});

Rails.start();
