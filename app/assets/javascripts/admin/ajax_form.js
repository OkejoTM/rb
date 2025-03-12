import { noty_success, noty_error } from './init_noty.js'
import { ajaxFormConstructor } from 'ajax-form.js'

function successMessage(event) {
  let data = event.detail[0];
  noty_success(data['notice']);
}

function errorMessage(event) {
  if(typeof event === 'string') {
    noty_error(event);
  } else {
    let data = event.detail[0];
    noty_error(data['notice']);
  }
}

$(function () {
  let ajaxForm = ajaxFormConstructor(successMessage, errorMessage);

  ajaxForm('form[data-ajax-submit]');
});
