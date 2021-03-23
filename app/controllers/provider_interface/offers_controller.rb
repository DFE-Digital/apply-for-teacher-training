module ProviderInterface
  class OffersController < ProviderInterfaceController
    before_action :set_application_choice
    before_action :confirm_application_is_in_decision_pending_state, except: %i[edit update show]
    before_action :confirm_application_is_in_offer_state, only: %i[edit update show]
    before_action :requires_make_decisions_permission

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
                                offer_context_params(@application_choice.offered_course_option,
                                                     @application_choice.offer['conditions'],
                                                     :change_offer).merge!(current_step: :offer))
      @wizard.configure_additional_conditions(@application_choice.offer['conditions'] - MakeAnOffer::STANDARD_CONDITIONS)
      @wizard.save_state!

      @providers = available_providers
      @courses = available_courses(@application_choice.offered_course.provider_id)
      @course_options = available_course_options(@application_choice.offered_course.id, @application_choice.offered_course_option.study_mode)
    end

    def update
      @wizard = OfferWizard.new(offer_store)
      if @wizard.valid?(:save)
        ChangeAnOffer.new(actor: current_provider_user,
                          application_choice: @application_choice,
                          course_option: @wizard.course_option,
                          offer_conditions: @wizard.conditions).save
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

    def confirm_application_is_in_offer_state
      return if %i[offer].include?(@application_choice.status.to_sym)

      redirect_to(provider_interface_application_choice_path(@application_choice))
    end

    def action
      'back' if !!params[:back]
    end

    def available_providers
      current_provider_user.providers
    end

    def available_courses(provider_id)
      Course.where(provider_id: provider_id)
    end

    def available_course_options(course_id, study_mode)
      CourseOption.where(course_id: course_id, study_mode: study_mode)
                  .includes(:site).order('sites.name')
    end

    def offer_context_params(course_option, conditions = MakeAnOffer::STANDARD_CONDITIONS, decision = :default)
      {
        provider_user_id: current_provider_user.id,
        course_id: course_option.course.id,
        course_option_id: course_option.id,
        provider_id: course_option.provider.id,
        study_mode: course_option.study_mode,
        location_id: course_option.site.id,
        decision: decision,
        standard_conditions: conditions,
      }
    end
  end
end
