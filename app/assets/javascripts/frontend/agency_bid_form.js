import { disableBtnByCheckboxHook } from '../shared/hooks.js'
import { AjaxFormSender } from '../shared/ajax_form_sender.js'
import { contactWays } from "./contact_ways.js"

$(function () {
  let $submit_btn = $("#submit_agency_feedback_btn");

  disableBtnByCheckboxHook($submit_btn, $('#i_agree'));

  $submit_btn.click(function (e) {
    e.preventDefault();

    let $phone = document.querySelector('#phone');
    let phone = intlTelInputGlobals.getInstance($phone);

    let req_props = {
      agency_bid: {
        name: $('#name').val(),
        phone: phone.getNumber(),
        email: $('#email').val(),
        country_id: $('#country_id').val(),
        agency_name: $('#agency_name').val(),
        message: $('#message').val(),
        website: $('#website').val(),
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
    form_sender.send(req_props, `/${PROPIMO_LOCALE}/agency_bid_form`);
  });
});
