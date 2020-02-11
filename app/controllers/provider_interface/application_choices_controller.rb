module ProviderInterface
  class ApplicationChoicesController < ProviderInterfaceController
    helper_method :toggle_sort_order

    def index
      @sort_order = params[:sort_order] ||= :desc

      application_choices = GetApplicationChoicesForProviders.call(providers: current_provider_user.providers)
        .order(updated_at: @sort_order)

      @application_choices = application_choices
    end

    def show
      @application_choice = GetApplicationChoicesForProviders.call(providers: current_provider_user.providers)
        .find(params[:application_choice_id])
    end

    private
    def toggle_sort_order(sort_order)
      sort_order.to_sym == :desc ? :asc : :desc
    end
  end
end
