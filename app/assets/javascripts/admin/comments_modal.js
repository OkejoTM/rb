import { disableBtnByInputHook } from '../shared/hooks.js'
import { AjaxFormSender } from '../shared/ajax_form_sender.js'
import { deleteBtn } from "../shared/components";

// Скрывает/Показывает лейбл с фразой "Комментарии отсутствуют"
// @param state [String] hide|show
function noCommentsLabelToggle(state) {
  if(state === 'hide') {
    $('#no_comments_label_id').hide();
  } else {
    $('#no_comments_label_id').show();
  }
}

// Скрывает/Показывает gif с загрузкой
// @param state [String] hide|show
function loaderToggle(state) {
  if(state === 'hide') {
    $('#comments_list_loader_id').hide();
  } else {
    $('#comments_list_loader_id').show();
  }
}

// Скрывает/Показывает Таблицу комментариев
// @param state [String] hide|show
function commentsTableToggle(state) {
  if(state === 'hide') {
    $('#comments_table').hide();
  } else {
    $('#comments_table').show();
  }
}

// Очищает подсказки валидаций, сообщения об ошибках
function clearModal() {
  noCommentsLabelToggle('hide');

  $('#comment-notification').hide();
  $('.help-block').hide().empty();

  $('#comments_table > tbody').empty();

  commentsTableToggle('hide');
}

// изменяет счетчик комментариев активной модалки
// @param change_of_counter [Integer] число на которое нужно изменить счетчик
function changeCounter(change_of_counter) {
  let $counter = $('.active-modal > #comments_count');
  let current_counter = parseInt($counter.html(), 10);
  let counter = current_counter + change_of_counter;

  if(counter === 0) {
    $counter.hide()
  } else {
    $counter.show();
  }
  $counter.html(counter);
}

// изменяет текст последнего комментария под кнопкой
// @param comment [Object] объект комментария
// @param type [String] new|delete режим изменения
function changeLastComment(comment, type) {
  let $last_comment = $('.active-modal').parent().siblings("[data-last_comment_id]");

  let new_message = '';
  let new_id = '';

  if(type === "new") {
    new_id = comment['id'];
    new_message = comment['message'];

  } else if (type === 'delete') {
    if($last_comment.data('last_comment_id') === comment['id']) { //Если был удален последний комментарий
      let $previous_comment = $('#comments_table > tbody > tr:last-child');
      if(!_.isEmpty($previous_comment)) {
        new_message = $previous_comment.children('[data-commentary_message]').html();
        new_id = $previous_comment.data('comment_id');
      }
    } else {
      return;
    }
  }

  $last_comment.data('last_comment_id', new_id);
  $last_comment.html(new_message);
}

// Добавляет комментарий в конец таблицы комментариев
// @param comment [Object] объект с полями комментария
function appendCommentary(comment) {
  let comment_id = comment['id'];

  let after_delete = () => {
    changeCounter(-1);
    let $table = $('#comments_table > tbody > tr');
    if(_.isEmpty($table)) {
      noCommentsLabelToggle('show');
    }
    changeLastComment(comment, 'delete');
  };

  $('#comments_table > tbody').append(commentRow(comment));

  deleteBtn(
    `/comments/${comment_id}.json`,
    comment_id,
    $(`tr[data-comment_id=${comment_id}] > [data-delete_btn]`),
    after_delete
  )
}

// Формирует строку для таблицы
// @param comment [Object] объект с полями комментария
// @return [String]
function commentRow(commentary) {
  return `<tr data-comment_id="${commentary['id']}">
    <td>${commentary['author_name']}</td>
    <td data-commentary_message>${commentary['message']}</td>
    <td>${commentary['created_at']}</td>
    <td data-delete_btn></td>
  </tr>`
}

// Коллбэк, открывающий модалку
// @param e [Object] событие
function showModal(e) {
  e.preventDefault();

  let $modal = $('#comments_modal_id');

  if($modal.length === 0) {
    return
  }

  clearModal();

  $modal.modal('show');

  let commentable_id = $(this).data('commentable_id');
  let commetable_type = $(this).data('commentable_type');
  $(this).addClass('active-modal'); //Помечаем какой кнопкой была открыта модалка

  loadComments(commentable_id, commetable_type);
}

// Загружает запросом комментарии для определенного типа объекта
// @param commentable_id [String] id объекта
// @param commentable_type [String] имя класса модели(ActiveRecord)
function loadComments(commentable_id, commentable_type) {
  let loadFailed = (jqXHR, textStatus, errorThrown) => {
    alert('Невозможно загрузить комментарии');
  };

  let loadSucceeded = (data) => {
    if (_.isEmpty(data)) {
      noCommentsLabelToggle('show');
    } else {
      commentsTableToggle('show');

      data.forEach((commentary) => {
        appendCommentary(commentary)
      });
    }
  };

  let loadAttempt = () => {
    loaderToggle('hide');
  };

  $.ajax({
    method: "GET",
    url: '/comments',
    data: {
      commentable_id: commentable_id,
      commentable_type: commentable_type
    },
    dataType: "json",
    beforeSend: () => {
      loaderToggle('show');
    }
  }).done(loadSucceeded)
    .fail(loadFailed)
    .always(loadAttempt);
}

// Коллбэк, добавляющий новый комментарий в БД
// @param e [Object] событие
function sendCommentary(e) {
  e.preventDefault();

  let active_block = $('.active-modal').first();
  let commentable_id = active_block.data('commentable_id');
  let commetable_type = active_block.data('commentable_type');

  let req_props = {
    comment: {
      item_type: commetable_type,
      item_id: commentable_id,
      message: $('#comment_message').val(),
      created_by_id: $('#created_by').val(),
    }
  };

  let $form_section = $('#comment-block');

  let ajax_form_sender = new AjaxFormSender(
    $form_section.find('.help-block'),
    $('#comments_list_loader_id'),
    $form_section,
    $('#comment-notification'),
    $(this)
  );

  ajax_form_sender.afterSuccess = function(data) {
    appendCommentary(data['comment']);
    $('#comment_message').val('');
    commentsTableToggle('show');
    noCommentsLabelToggle('hide');
    changeCounter(1);
    changeLastComment(data['comment'], 'new');
  };

  ajax_form_sender.send(req_props, `/comments`);
}

$(function () {
  let $show_comments_modal_btns = $('[data-comments_dialog]');
  let $submit_comment_btn = $('#submit_comment_id');
  let $comment_input = $('#comment_message');

  //Хук отключающий кнопку, если в инпуте пусто
  disableBtnByInputHook($submit_comment_btn, $comment_input);

  $submit_comment_btn.click(sendCommentary);

  $show_comments_modal_btns.click(showModal);

  //Коллбэк убирающий с кнопки пометку о том, что эта кнопка открыла модалку
  $('#comments_modal_id').on('hide.bs.modal', function (e) {
    $('.active-modal').removeClass('active-modal');
  });
});
