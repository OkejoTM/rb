function deleteForm() {
  let $btn_delete = $(this);

  let $form = $btn_delete.parents('[data-form-root]');
  let id = $form.data('tag-index');

  if(id === undefined) {
    // Новый элемент
    $form.remove();
  } else {
    // Старый элемент
    $form.append(`<input type='hidden' name='property_tag[property_tag_aliases_attributes][${id}][_destroy]' value="1" />`);
    $form.hide();
  }
}
function initializeForm($elem) {
  let $btn_delete = $elem.find('[data-tag-remove-index]');

  $btn_delete.on('click', deleteForm);
}

$(function () {
  let $template = $('[data-template="property_tag_alias"]').children().last();
  let $forms_container = $('[data-forms-container]');
  let $btn_add = $('#add-alias-tag');

  $forms_container.children().each(function () {
    initializeForm($(this));
  });

  $btn_add.on('click', function () {
    let $clonedElement = $template.clone();
    let $input = $clonedElement.find('.tag-input');
    let countElements = $forms_container.find('.form-group.row').length;

    $input.prop('name', `property_tag[property_tag_aliases_attributes][${countElements + 1}][name]`);
    $forms_container.append($clonedElement);

    initializeForm($clonedElement);
  });
});
