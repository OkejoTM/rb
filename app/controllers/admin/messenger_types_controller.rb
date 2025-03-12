class Admin::MessengerTypesController < Admin::BasicAdminController

  init_resource :messenger_type
  define_actions :index, :show, :new, :edit, :create, :update, :destroy

  private

    def show_hook
      add_breadcrumb t(:index, scope: :messenger_types), :messenger_types_path

      add_breadcrumb @object.title

      @page_title = @object.title
    end
end
