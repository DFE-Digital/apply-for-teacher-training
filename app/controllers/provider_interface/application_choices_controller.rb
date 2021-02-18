module ProviderInterface
  class ApplicationChoicesController < ProviderInterfaceController
    before_action :set_application_choice, except: %i[index]
    before_action :set_workflow_flags, except: %i[index]

    def index
      @filter = ProviderApplicationsFilter.new(
        params: params,
        provider_user: current_provider_user,
        state_store: session,
      )

      application_choices = GetApplicationChoicesForProviders.call(
        providers: available_providers,
      )

      application_choices = FilterApplicationChoicesForProviders.call(
        application_choices: application_choices,
        filters: @filter.applied_filters,
      )

      # Eager load / prevent Bullet::Notification::UnoptimizedQueryError
      with_includes = ApplicationChoice.includes(
        %i[application_form provider offered_course_option site accredited_provider],
      )

      # Using id: below turns all previous queries into a subquery for sorting
      # which preserves the virtual attributes from the sorting SELECT
      application_choices = ProviderInterface::SortApplicationChoices.call(
        application_choices: with_includes.where(id: application_choices),
      )

      @application_choices_count = application_choices.count
      @application_choices = application_choices.page(params[:page] || 1).per(30)
    end

    def show
      @show_language_details = @application_choice
        .application_form
        .english_main_language(fetch_database_value: true)
        .present?
    end

    def offer
      @status_box_options = { provider_can_respond: @provider_can_respond }

      if @application_choice.offer? && @provider_can_respond
        @status_box_options.merge!(get_all_change_options(@application_choice))
      end
    end

    def timeline; end

    def feedback; end

    def emails
      if HostingEnvironment.sandbox_mode?
        @emails = Email.includes(:application_form)
          .where(application_form_id: @application_choice.application_form)
      else
        render_403
      end
    end

  private

    def available_providers
      current_provider_user.providers
    end

    def set_workflow_flags
      @provider_can_respond = get_provider_can_respond
      @offer_present = ApplicationStateChange::OFFERED_STATES.include?(@application_choice.status.to_sym)
    end

    def get_all_change_options(application_choice)
      GetAllChangeOptionsFromOfferedOption.new(
        application_choice: application_choice,
        available_providers: available_providers,
      ).call
    end

    def get_provider_can_respond
      auth = ProviderAuthorisation.new(actor: current_provider_user)
      @provider_can_respond = auth.can_make_decisions?(
        application_choice: @application_choice,
        course_option_id: @application_choice.offered_option.id,
      )
    end
  end
end
