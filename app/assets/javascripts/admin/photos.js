$(function () {

  function readFileAsync(file) {
    return new Promise((resolve, reject) => {
      let reader = new FileReader();

      reader.onload = () => {
        resolve(reader.result);
      };

      reader.onerror = reject;

      reader.readAsDataURL(file);
    })
  }

  const template = (id, image) => {
    return `<div id="${id}"
                 class="col-md-3"
                 data-preview
            >
      <figure class="figure">
        <div class="photo-container">
          <img src="${image}"
               class="figure-img img-fluid resized_image"
          />
        </div>
      </figure>
    </div>`
  };

  function processImage(image) {
    let $images = $('#new_pictures');
    $images.append(template('', image));
  }

  function loadImages(files, process_image) {
    for (const file of files) {
      readFileAsync(file).then(process_image);
    }
  }

  function clearImages() {
    $('#new_pictures [data-preview]').remove();
  }

  function hideImagesBlock(toggle) {
    let $images = $('#new_pictures');
    let $images_title = $('#new_pictures_title');
    $images.children().remove();
    $images.toggleClass('hide', toggle);
    $images_title.toggleClass('hide', toggle);
  }

  function updatePhotos(thumbnails_html) {
    let $photos_block = $('#property_pictures');
    $photos_block.children().remove();
    $photos_block.append(thumbnails_html);
  }

  $('#load_images').on('change', function (e) {
    let $input = $(e.currentTarget);
    let files = $input[0].files;

    if(files.length === 0) {
      hideImagesBlock(true);
      return;
    }

    hideImagesBlock(false);

    clearImages();
    loadImages(files, processImage)

  });

  $('#properties_form').on('ajax:success', function(data) {
    let response = _.get(data, ['detail', '0', 'photos']);
    hideImagesBlock(true);
    updatePhotos(response);
  });
});
