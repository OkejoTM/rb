import * as intlTelInput from 'intl-tel-input/build/js/intlTelInput.js' //Замешивает в window переменную intlTelInputGlobals
import 'intl-tel-input/build/js/utils.js'

const config = {
  nationalMode: false,
  autoPlaceholder: 'aggressive',
  separateDialCode: true,
  initialCountry: "US",
  preferredCountries: ['ru', 'it', 'gr', 'us']
};

// Инициализирует intl-tel-input, если он еще не был проинициализирован
// @param input [Object] DOM-element (не JQuery!)
// @param config [Hash] настройки плагина
function safeInit (input, config) {
  let instance = intlTelInputGlobals.getInstance(input);

  if(instance) {
    return
  }

  intlTelInput(input, config);
}
export {
  config,
  safeInit
};
