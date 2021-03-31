module ProviderInterface
  class OffersController < ProviderInterfaceController
    before_action :set_application_choice
    before_action :confirm_application_is_in_decision_pending_state, except: %i[edit update show]
    before_action :confirm_application_is_in_offered_state, only: %i[edit update show]
    before_action :requires_make_decisions_permission, except: %i[show]

    def new
      flash[:warning] = t('.failure')
      redirect_to new_provider_interface_application_choice_decision_path(@application_choice)
    end

    def create
      @wizard = OfferWizard.new(offer_store)
      if @wizard.valid?(:save)
        MakeOffer.new(actor: current_provider_user,
                      application_choice: @application_choice,
                      course_option: @wizard.course_option,
                      conditions: @wizard.conditions).save!
        @wizard.clear_state!

        flash[:success] = t('.success')
        redirect_to provider_interface_application_choice_offer_path(@application_choice)
      else
        @wizard.clear_state!

        flash[:warning] = t('.failure')
        redirect_to new_provider_interface_application_choice_decision_path(@application_choice)
      end
    end

    def edit; end

    def show
      @wizard = OfferWizard.new(offer_store,
                                offer_context_params(:change_offer).merge!(current_step: :offer))
      @wizard.configure_additional_conditions(@application_choice.offer['conditions'] - MakeAnOffer::STANDARD_CONDITIONS)
      @wizard.save_state!

      return unless provider_user_can_make_decisions

      @providers = available_providers
      @courses = available_courses(@application_choice.offered_course.provider.id)
      @course_options = available_course_options(@application_choice.offered_course.id, @application_choice.offered_course_option.study_mode)
    end

    def update
      @wizard = OfferWizard.new(offer_store)
      if @wizard.valid?(:save)
        ::ChangeOffer.new(actor: current_provider_user,
                          application_choice: @application_choice,
                          course_option: @wizard.course_option,
                          conditions: @wizard.conditions).save!
        @wizard.clear_state!

        flash[:success] = t('.success')
      else
        @wizard.clear_state!

        flash[:warning] = t('.failure')
      end
      redirect_to provider_interface_application_choice_offer_path(@application_choice)
    end

  private

    def offer_store
      key = "offer_wizard_store_#{current_provider_user.id}_#{@application_choice.id}"
      WizardStateStores::RedisStore.new(key: key)
    end

    def confirm_application_is_in_decision_pending_state
      return if ApplicationStateChange::DECISION_PENDING_STATUSES.include?(@application_choice.status.to_sym)

      redirect_to(provider_interface_application_choice_path(@application_choice))
    end

    def confirm_application_is_in_offered_state
      return if ApplicationStateChange::OFFERED_STATES.include?(@application_choice.status.to_sym)

      redirect_to(provider_interface_application_choice_path(@application_choice))
    end

    def action
      'back' if !!params[:back]
    end

    def available_providers
      query_service.available_providers
    end

    def available_courses(provider_id)
      query_service.available_courses(provider: Provider.find(provider_id))
    end

    def available_course_options(course_id, study_mode)
      query_service.available_course_options(course: Course.find(course_id), study_mode: study_mode)
    end

    def query_service
      @query_service ||= GetChangeOfferOptions.new(
        user: current_provider_user,
        current_course: @application_choice.offered_course,
      )
    end

    def offer_context_params(decision = :default)
      course_option = @application_choice.offered_option
      conditions = @application_choice.offer['conditions'] || MakeAnOffer::STANDARD_CONDITIONS

      {
        provider_user_id: current_provider_user.id,
        application_choice_id: @application_choice.id,
        course_id: course_option.course.id,
        course_option_id: course_option.id,
        provider_id: course_option.provider.id,
        study_mode: course_option.study_mode,
        location_id: course_option.site.id,
        decision: decision,
        standard_conditions: conditions,
      }
    end

    helper_method :provider_user_can_make_decisions

    def provider_user_can_make_decisions
      @provider_can_make_decisions = current_provider_user.authorisation.can_make_decisions?(
        application_choice: @application_choice,
        course_option_id: @application_choice.offered_option.id,
      )
    end
  end
end
