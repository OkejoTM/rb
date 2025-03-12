function deleteBtn(link, id, $btn_col, afterSuccess) {

  if(_.isNil(afterSuccess)) {
    afterSuccess = (data) => {};
  }

  let btn_html =
    `<a href="${link}" 
        class="btn btn-default"
    >
      <i class="glyphicon glyphicon-remove"></i>
    </a>`;

  $btn_col.html(btn_html);

  $(`a[href="${link}"]`).on('click', function (e) {
    e.preventDefault();
    if (!confirm("Вы уверены что хотите удалить комментарий?")) { return; }

    let deleteSucceeded = (data) => { $(`tr[data-comment_id=${id}]`).remove(); afterSuccess(data); };
    let deleteFailed = (data) => { alert('Произошла ошибка при удалении'); };

    $.ajax({
      method: "DELETE",
      url: link,
      dataType: "json"
    }).done(deleteSucceeded)
      .fail(deleteFailed)
  });
}

export { deleteBtn }
