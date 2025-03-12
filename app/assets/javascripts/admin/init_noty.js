let Noty = require('noty');
// window.Noty = require('noty');

Noty.overrideDefaults({
    theme: 'bootstrap-v3',
    timeout: 3000,
    progressBar: true,
    closeWith: ['click', 'button']
});

// window.noty_success = function (text) {
function noty_success(text) {
    new Noty({
        text: text,
        type: 'success'
    }).show();
};

// window.noty_error = function (text) {
function noty_error(text) {
    new Noty({
        text: text,
        type: 'error'
    }).show();
};

export { Noty, noty_success, noty_error }