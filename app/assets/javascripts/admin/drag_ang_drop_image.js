$(function () {
    let $images = $('.drag_and_drop_image');

    function insertAfter(elem, refElem) {
        const parent = refElem.closest('.col-md-2');
        return parent.parentNode.insertBefore(elem, parent.nextSibling);
    }

    $images.on("drop", function (ev) {
        ev.dataTransfer = ev.originalEvent.dataTransfer;

        ev.preventDefault();
        // Получаем передвигаемую картинку
        let srcId = ev.dataTransfer.getData("image_id");
        let src = document.getElementById(srcId);

        // Меняем две картинки местами
        let srcParent = src.parentNode;
        if (srcParent.id == "property_pictures") {
            var tgt = ev.target.closest('.col-md-2');
            if (ev.clientX < tgt.getBoundingClientRect().left + tgt.offsetWidth / 2) {
                srcParent.insertBefore(src, tgt);
                console.log("Insert before");
            } else {
                insertAfter(src, tgt);
                console.log("Insert after");
            }
        }
        // Удаляем класс highlight из всех элементов .col-md-2
        $('.col-md-2').removeClass('highlight');
    });

    $images.on("dragover", function (ev) {
        ev.preventDefault();
        let tgt = $(ev.target).closest('.col-md-2');

        // Проверяем, не соприкасается ли перетаскиваемый элемент с границами текущего фото
        if (!tgt.hasClass('dragged')) {
            tgt.addClass(ev.clientX < tgt.offset().left + tgt.outerWidth() / 2 ? 'highlight left' : 'highlight right');
        }
    });

    $images.on("dragleave dragend", function(ev) {
        ev.preventDefault();
        $('.col-md-2').removeClass('highlight left right');
    });

    $images.on("dragstart", function (ev) {
        ev.dataTransfer = ev.originalEvent.dataTransfer;
        let tgt = $(ev.target).closest('.col-md-2');

        // Добавляем класс 'dragged' к текущему фото при начале перетаскивания
        tgt.addClass('dragged');
        ev.dataTransfer.setData("image_id", ev.target.parentNode.id);
    });

    $images.on("dragend", function(ev) {
        ev.preventDefault();
        $('.col-md-2').removeClass('highlight left right');

        // Удаляем класс 'dragged' из всех фото после окончания перетаскивания
        $('.col-md-2').removeClass('dragged');
    });
});
