class Admin::PicturesController < Admin::BasicAdminController
  def destroy
    photo = Picture.find_by(id: params[:id])
    photo.destroy

    respond_to do |format|
      format.json do
        render json: { id: photo.id },
               status: :ok
      end
    end
  end
end
