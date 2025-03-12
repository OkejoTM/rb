import { disableBtnByCheckboxHook } from '../shared/hooks.js'
import { AjaxFormSender } from '../shared/ajax_form_sender.js'
import { contactWays } from "./contact_ways.js"

import { callMetrika } from './call_metrika.js'

$(function () {
  let submit_btn = $("#submit_message_btn");

  disableBtnByCheckboxHook(submit_btn, $('#i_agree'));

  submit_btn.click(function (e) {
    e.preventDefault();

    //Метрика для нажатия кнопки "Написать продавцу"
    callMetrika('submit-message-btn');

    let $phone = document.querySelector('#phone');
    let phone = intlTelInputGlobals.getInstance($phone);

    let req_props = {
      bid: {
        name: $('#name').val(),
        phone: phone.getNumber(),
        email: $('#email').val(),
        message: $('#message').val(),
        property_id: $('#property_id').val(),
        contact_ways_attributes: contactWays(),
      }
    };

    let form_sender = new AjaxFormSender(
      $('.help-block'),
      $('#loader'),
      $('#contact'),
      $('#contact-message'),
      $(this)
    );
    form_sender.send(req_props, `/${PROPIMO_LOCALE}/bids`);
  });

  //Метрика для нажатия кнопки "Написать продавцу"
  $('#write_seller').click(function () {
    callMetrika('write-seller-btn');
  });
});
