module ProviderInterface
  class OffersController < ProviderInterfaceController
    before_action :set_application_choice
    before_action :confirm_application_is_in_decision_pending_state
    before_action :requires_make_decisions_permission

    def new
      flash[:warning] = t('.failure')
      redirect_to new_provider_interface_application_choice_decision_path(@application_choice)
    end

    def create
      @wizard = OfferWizard.new(offer_store)
      if @wizard.valid?
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

  private

    def offer_store
      key = "offer_wizard_store_#{current_provider_user.id}_#{@application_choice.id}"
      WizardStateStores::RedisStore.new(key: key)
    end

    def confirm_application_is_in_decision_pending_state
      return if ApplicationStateChange::DECISION_PENDING_STATUSES.include?(@application_choice.status.to_sym)

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
  end
end
