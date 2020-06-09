module ProviderInterface
  class OfferChangesController < ProviderInterfaceController
    before_action :set_application_choice

    def edit_offer
      change_offer_form = \
        if change_offer_params.empty?
          ProviderInterface::ChangeOfferForm.new(
            application_choice: @application_choice,
            provider_id: @application_choice.offered_option.provider.id,
            course_id: @application_choice.offered_course.id,
            study_mode: @application_choice.offered_option.study_mode,
            course_option_id: @application_choice.offered_option.id,
            step: params[:step]&.to_sym,
          )
        else
          change_offer_form_from_params
        end

      if change_offer_form.step == :confirm && change_offer_form.new_offer?
        redirect_to_new_offer_flow(course_option_id: change_offer_form.course_option_id)
      end

      @change_offer_component = ProviderInterface::ChangeOfferComponent.new(
        change_offer_form: change_offer_form,
        providers: available_providers,
        completion_url: {
          action: :update_offer,
          application_choice_id: @application_choice.id,
        },
      )
    end

    def update_offer
      change_offer_form = change_offer_form_from_params
      change_offer_form.step = :update

      if change_offer_form.valid?
        ::ChangeOffer.new(
          actor: current_provider_user,
          application_choice: @application_choice,
          course_option: change_offer_form.selected_course_option,
        ).save
        redirect_to provider_interface_application_choice_path(@application_choice.id)
      else
        raise 'cannot update offer'
      end
    end

  private

    def available_providers
      current_provider_user.providers
    end

    def set_application_choice
      @application_choice = GetApplicationChoicesForProviders.call(
        providers: available_providers,
      ).find(params[:application_choice_id])
    end

    def change_offer_form_from_params
      ProviderInterface::ChangeOfferForm.new(
        application_choice: @application_choice,
        provider_id: change_offer_params[:provider_id]&.to_i,
        course_id: change_offer_params[:course_id]&.to_i,
        study_mode: change_offer_params[:study_mode],
        course_option_id: change_offer_params[:course_option_id]&.to_i,
        entry: change_offer_params[:entry],
        step: params[:step]&.to_sym,
      )
    end

    def change_offer_params
      params.require(:provider_interface_change_offer_form).permit(:provider_id, :course_id, :study_mode, :course_option_id, :entry)
    rescue ActionController::ParameterMissing
      {}
    end

    def redirect_to_new_offer_flow(course_option_id:)
      redirect_to \
        provider_interface_application_choice_new_offer_path(course_option_id: course_option_id)
    end
  end
end
