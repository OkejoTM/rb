/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'frontend' %> to the appropriate
// layout file, like app/views/layouts/frontend.html.erb

import 'images/listing-01.jpg'
import 'images/logo.png';
import 'images/logo2.png';
import 'images/loader.gif';
import 'images/map_bg.png';
import 'images/energy_efficiency/A++.png'
import 'images/energy_efficiency/A+.png'
import 'images/energy_efficiency/A.png'
import 'images/energy_efficiency/B.png'
import 'images/energy_efficiency/B+.png'
import 'images/energy_efficiency/C+.png'
import 'images/energy_efficiency/C.png'
import 'images/energy_efficiency/C-.png'
import 'images/energy_efficiency/D.png'
import 'images/energy_efficiency/E.png'
import 'images/energy_efficiency/F.png'
import 'images/energy_efficiency/G.png'
import '@fortawesome/fontawesome-free'

import 'javascripts/cable';
import 'javascripts/findeo';

import 'wpcc/cookieconsent.min.js';

import 'lazysizes';

let req = require.context("javascripts/frontend/", true, /^(.*\.(js\.*))[^.]*$/);
req.keys().forEach(function(key){
    req(key);
});
