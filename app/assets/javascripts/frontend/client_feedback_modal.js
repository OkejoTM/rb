import { disableBtnByCheckboxHook } from '../shared/hooks.js'
import { AjaxFormSender } from '../shared/ajax_form_sender.js'
import { contactWays } from "./contact_ways.js"
import { config, safeInit } from 'shared/intl_tel_input_config.js'

import { callMetrika } from './call_metrika.js'

//const MODAL_DELAY = 30000; //30 sec
const BEFORE_CLOSE_DELAY = 1000; //1 sec

function initializeIntlTelInput(){
  let $phone = $('#client_feedback_phone');
  safeInit($phone[0], config);
}

function showModal() {
  let $modal = $('#client_feedback_modal_id');

  if($modal.length === 0) {
    return
  }

  $('#feedback-message').hide();
  $('.help-block').hide().empty();

  callMetrika('show-client-feedback');
  $modal.modal('show');
  sessionStorage.setItem('feedback-modal-shown', 'true');

  $modal.on('shown.bs.modal', initializeIntlTelInput);
}

function closeModal() {
  $('#client_feedback_modal_id').modal('hide');
}

$(function () {
  if(PROPIMO_LOCALE !== 'ru') {
    return;
  }

  let $submit_btn = $("#submit_client_feedback_btn");
  let $show_modal_btn = $('#client-feedback-modal-btn');

  disableBtnByCheckboxHook($submit_btn, $('#i_agree_client_feedback'));

  $show_modal_btn.click(showModal);

  $submit_btn.click(function (e) {
    e.preventDefault();

    let $phone = document.querySelector('#client_feedback_phone');
    let phone = intlTelInputGlobals.getInstance($phone);

    let req_props = {
      client_feedback: {
        name: $('#client_feedback_name').val(),
        phone: phone.getNumber(),
        message: $('#client_feedback_message').val(),
        contact_ways_attributes: contactWays('modal'),
        source: window.location.href
      }
    };

    let $form_section = $('#client-feedback');

    let ajax_form_sender = new AjaxFormSender(
      $form_section.find('.help-block'),
      $('#loader_client_modal'),
      $form_section,
      $('#feedback-message'),
      $(this)
    );

    ajax_form_sender.afterSuccess = function() {
      setTimeout(closeModal, BEFORE_CLOSE_DELAY)
    };

    ajax_form_sender.send(req_props, `/${PROPIMO_LOCALE}/client_feedback`);
  });

//  if(sessionStorage.getItem('feedback-modal-shown') !== 'true') {
//    setTimeout(showModal, MODAL_DELAY);
//  }
});
