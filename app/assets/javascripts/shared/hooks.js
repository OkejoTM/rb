function disableBtnByCheckboxHook($btn, $checkbox) {
  $checkbox.click(function (e) {
    if ($(this).prop("checked")) {
      $btn.removeAttr("disabled").removeClass("disabled");
    } else {
      $btn.prop("disabled", true).addClass("disabled");
    }
  });
}

// TODO uneffecient?
function disableBtnByInputHook($btn, $input) {
  $input.on('input', function (e) {
    let value = e.target.value;

    if (_.isEmpty(value)) {
      $btn.prop("disabled", true).addClass("disabled");
    } else {
      $btn.removeAttr("disabled").removeClass("disabled");
    }
  });
}

export {
  disableBtnByCheckboxHook,
  disableBtnByInputHook
};
