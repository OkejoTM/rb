import { config, safeInit } from 'shared/intl_tel_input_config.js'

$(function () {
  $(".international-phone").each(function () {
    safeInit(this, config);
  });
});
