module ProviderInterface
  class ApplicationChoicesController < ProviderInterfaceController
    include ClearWizardCache

    before_action :set_application_choice, :set_workflow_flags, except: %i[index]
    before_action :redirect_if_application_changed_provider, only: %i[timeline]

    def index
      @filter = ProviderApplicationsFilter.new(
        params:,
        provider_user: current_provider_user,
        state_store: StateStores::RedisStore.new(key: state_store_key),
      )

      application_choices = GetApplicationChoicesForProviders.call(
        providers: available_providers,
      )

      application_choices = FilterApplicationChoicesForProviders.call(
        application_choices:,
        filters: @filter.applied_filters,
      )

      # Eager load / prevent Bullet::Notification::UnoptimizedQueryError
      with_includes = ApplicationChoice.includes(
        %i[application_form current_course_option current_course current_site current_provider current_accredited_provider],
      )

      # Using id: below turns all previous queries into a subquery for sorting
      # which preserves the virtual attributes from the sorting SELECT
      application_choices = ProviderInterface::SortApplicationChoices.call(
        application_choices: with_includes.where(id: application_choices),
      )

      @application_choices = application_choices.page(params[:page] || 1).per(30).load
    end

    def show
      clear_wizard_if_new_entry(CourseWizard.new(change_course_store, {}))

      @wizard = CourseWizard.build_from_application_choice(
        change_course_store,
        @application_choice,
        provider_user_id: current_provider_user.id,
        current_step: 'select_option',
      )

      @wizard.save_state!

      @show_language_details = @application_choice
        .application_form
        .english_main_language(fetch_database_value: true)
        .present?

      @available_training_providers = available_training_providers
      @available_courses = available_courses
      @available_course_options = available_course_options

      @show_updated_recently_banner = @application_choice.updated_recently_since_submitted?
    end

    def timeline; end

    def feedback
      redirect_to provider_interface_application_choice_path(@application_choice) unless @application_choice.display_provider_feedback?
    end

    def emails
      if HostingEnvironment.sandbox_mode?
        @emails = Email.includes(:application_form)
          .where(application_form_id: @application_choice.application_form)
      else
        render_403
      end
    end

    def application_withdrawable?
      @provider_user_can_make_decisions && ApplicationStateChange::UNSUCCESSFUL_STATES.exclude?(@application_choice.status.to_sym)
    end
    helper_method :application_withdrawable?

  private

    def available_providers
      current_provider_user.providers
    end

    def available_training_providers
      query_service.available_providers
    end

    def available_courses
      query_service.available_courses(provider: @application_choice.current_provider)
    end

    def available_course_options
      query_service.available_course_options(course: @application_choice.course, study_mode: @application_choice.course.study_mode)
    end

    def query_service
      @query_service ||= GetChangeOfferOptions.new(
        user: current_provider_user,
        current_course: @application_choice.current_course,
      )
    end

    def state_store_key
      CacheKey.generate("#{ProviderApplicationsFilter::STATE_STORE_KEY}_#{current_provider_user.id}")
    end

    def change_course_store
      key = "change_course_wizard_store_#{current_provider_user.id}_#{@application_choice.id}"
      WizardStateStores::RedisStore.new(key:)
    end

    def wizard_entrypoint_paths
      [
        edit_provider_interface_application_choice_course_providers_path,
        edit_provider_interface_application_choice_course_courses_path,
        edit_provider_interface_application_choice_course_study_modes_path,
        edit_provider_interface_application_choice_course_locations_path,
        edit_provider_interface_application_choice_course_check_path,
      ].freeze
    end
  end
end
