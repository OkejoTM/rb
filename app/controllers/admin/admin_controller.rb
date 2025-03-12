class Admin::AdminController < Admin::BasicAdminController

  # GET /admin
  def main
    render 'index'
  end

  # POST /image_upload
  def image_upload
    # Сохранить картинку
    picture = Picture.create(pic: params[:upload].tempfile)

    # Сгенерировать массив ссылок на разные версии картинки
    # urls = {
    #     urls: {
    #       dafault: '/images/home-parallax.jpeg',
    #       '100' => '/images/home-parallax.jpeg'
    #     }
    # }

    render json: { url: picture.pic.url }, status: :ok
  end
end
