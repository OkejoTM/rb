class Admin::ContactPeopleController < Admin::BasicAdminController

  init_resource :contact_person
  define_actions :destroy

  # GET /contact_people
  # GET /contact_people.json
  def index
    contact_people = ContactPerson.all.preload(:agency)

    @pagination = Pagination.new(contact_people, current_page: params[:page].to_i, page_size: 100)

    add_breadcrumb t(:index, scope: :contact_people), :contact_people_path

    @page_title = t(:index, scope: :contact_people)

    respond_to do |format|
      format.html
      format.json { render json: @contact_people }
    end
  end
end
