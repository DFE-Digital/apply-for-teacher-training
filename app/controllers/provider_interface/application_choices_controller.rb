module ProviderInterface
  class ApplicationChoicesController < ProviderInterfaceController
    before_action :set_application_choice_and_sub_navigation_items, except: %i[index]

    def index
      @page_state = ProviderApplicationsPageState.new(
        params: params,
        provider_user: current_provider_user,
      )

      application_choices = GetApplicationChoicesForProviders.call(
        providers: current_provider_user.providers,
      )

      if FeatureFlag.active?('provider_application_filters')
        application_choices = FilterApplicationChoicesForProviders.call(
          application_choices: application_choices,
          filters: @page_state.filter_selections,
        )
      end
      application_choices = application_choices.page(params[:page] || 1)
      @application_choices = application_choices.order(@page_state.applications_ordering_query)
    end

    def show
      @status_box_options = if @application_choice.offer?
                              GetAllChangeOptionsFromOfferedOption.new(
                                application_choice: @application_choice,
                                available_providers: available_providers,
                              ).call
                            else
                              {}
                            end
    end

    def notes
      redirect_to(action: :show) unless FeatureFlag.active?('notes')
    end

    def timeline
      redirect_to(action: :show) unless FeatureFlag.active?('timeline')
    end

  private

    def available_providers
      current_provider_user.providers
    end

    def set_application_choice_and_sub_navigation_items
      @application_choice = get_application_choice
      @sub_navigation_items = get_sub_navigation_items
    end

    def get_application_choice
      GetApplicationChoicesForProviders.call(
        providers: available_providers,
      ).find(params[:application_choice_id])
    end

    def get_sub_navigation_items
      sub_navigation_items = [
        { name: 'Application', url: provider_interface_application_choice_path(@application_choice) },
      ]

      if FeatureFlag.active?('notes')
        sub_navigation_items.push(
          { name: 'Notes', url: provider_interface_application_choice_notes_path(@application_choice) },
        )
      end

      if FeatureFlag.active?('timeline')
        sub_navigation_items.push(
          { name: 'Timeline', url: provider_interface_application_choice_timeline_path(@application_choice) },
        )
      end

      sub_navigation_items
    end
  end
end
