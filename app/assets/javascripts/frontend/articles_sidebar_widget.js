$(function () {
  let $banner = $('#articles_sticky_widget');

  // Для мобильных экранов не двигаем блок со статьями
  if ($banner.length <= 0 || window.innerWidth <= 768) {
    return
  }

  // закрепляем ширину блока статей
  let banner_width = $banner.width();
  $banner.css('width', banner_width);

  let margin_top = 21;
  let offset_top = null;

  // на размере окна шириной 1024 не приклеивается шапка, поэтому отступаем без его учета
  if (window.innerWidth <= 1024) {
    offset_top = margin_top;
  } else {
    offset_top = $('#header-container').height() + margin_top;
  }

  let properties_form = $('#properties_form');
  let starting_point = properties_form.outerHeight(true) + properties_form.offset().top;
  let $properties = $('#properties_list .listings-container');

  $(window).scroll(function() {
    let current_window_top = $(window).scrollTop() + offset_top;

    if (current_window_top > starting_point) {
      $banner.css('position', 'fixed');

      let properties_height = $properties.offset().top + $properties.outerHeight(true);
      let calculated_top = properties_height - $(window).scrollTop() - $banner.height() + margin_top;
      let min_top = Math.min(offset_top, calculated_top);
      $banner.css('top', min_top);
    } else {
      $banner.css('position', 'static');
    }
  })
});
