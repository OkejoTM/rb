class AjaxFormSender {

  constructor($help_blocks, $loader, $form_section, $message, $send_btn) {
    this.$help_blocks = $help_blocks;
    this.$loader = $loader;
    this.$form_section = $form_section;
    this.$message = $message;
    this.$send_btn = $send_btn;

    this.success = this.success.bind(this);
    this.error = this.error.bind(this);
    this.beforeSend = this.beforeSend.bind(this);
  }

  send(req_props, url) {
    $.ajax({
      method: "POST",
      url: url,
      data: req_props,
      dataType: "json",
      beforeSend: this.beforeSend
    }).done(this.success)
      .error(this.error)
  }

  beforeSend(jqXHR, settings) {
    this.$message.hide();
    this.$form_section.addClass('loading');
    this.$loader.show();
  }

  success(data) {
    this.hideLoader();
    this.hideErrors();

    this.$send_btn.prop("disabled", true).addClass("disabled");

    this.showNotice(data['notice']);
    this.afterSuccess(data);
  }

  afterSuccess(data) { /* Метод для переопределения */ }

  error(data) {
    this.hideLoader();
    this.hideErrors();

    this.showFieldErrors(data);

    this.showNotice(data.responseJSON['notice']);
  }

  showNotice(notice) {
    this.$message.html(notice).slideDown();
  }

  hideErrors() {
    this.$help_blocks.hide().empty();
  }

  hideLoader() {
    this.$loader.hide();
    this.$form_section.removeClass('loading');
  }

  showFieldErrors(data) {
    let errors = data.responseJSON['errors'];

    if (_.isNil(errors)) {
      return
    }

    for (let key in errors) {
      let elem_id = key.replace(/\./g, '_') + '_error';
      let elem = this.$form_section.find(`#${elem_id}`);
      elem.show();

      errors[key].forEach((value) => {
        elem.append(`<div>${value}</div>`);
      });
    }
  }
}

export { AjaxFormSender };
