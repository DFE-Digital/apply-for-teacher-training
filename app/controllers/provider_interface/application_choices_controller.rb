module ProviderInterface
  class ApplicationChoicesController < ProviderInterfaceController
    def index
      @sort_order = params[:sort_order] ||= 'desc'
      @sort_by = params[:sort_by] ||= 'last-updated'

      application_choices = GetApplicationChoicesForProviders.call(providers: current_provider_user.providers)
                              .order(query_mapping[@sort_by])

      @application_choices = application_choices
    end

    def show
      @application_choice = GetApplicationChoicesForProviders.call(providers: current_provider_user.providers)
        .find(params[:application_choice_id])
    end

  private

    def query_mapping
      {
        'course' => { 'courses.name' => @sort_order },
        'last-updated' => { 'application_choices.updated_at' => @sort_order },
        'name' => { 'last_name' => @sort_order, 'first_name' => @sort_order },
      }
    end
  end
end
