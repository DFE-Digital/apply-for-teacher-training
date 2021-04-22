module ProviderInterface
  module Offer
    class StudyModesController < OffersController
      def new
        @wizard = OfferWizard.new(offer_store, { decision: 'change_offer', current_step: 'study_modes', action: action })
        @wizard.save_state!

        @course = Course.find(@wizard.course_id)
        @study_modes = available_study_modes(@course)
      end

      def create
        @wizard = OfferWizard.new(offer_store, attributes_for_wizard)
        @wizard.course_option_id = nil if @wizard.course_option_id && @wizard.course_option.study_mode != @wizard.study_mode

        if @wizard.valid_for_current_step?
          @wizard.save_state!

          redirect_to [:new, :provider_interface, @application_choice, :offer, @wizard.next_step]
        else
          @course = Course.find(@wizard.course_id)
          @study_modes = available_study_modes(@course)

          render :new
        end
      end

      def edit
        @wizard = OfferWizard.new(offer_store, { current_step: 'study_modes', action: action })
        @wizard.save_state!

        @course = Course.find(@wizard.course_id)
        @study_modes = available_study_modes(@course)
      end

      def update
        @wizard = OfferWizard.new(offer_store, attributes_for_wizard)
        @wizard.course_option_id = nil if @wizard.course_option_id && @wizard.course_option.study_mode != @wizard.study_mode

        if @wizard.valid_for_current_step?
          @wizard.save_state!

          redirect_to [:edit, :provider_interface, @application_choice, :offer, @wizard.next_step]
        else
          @course = Course.find(@wizard.course_id)
          @study_modes = available_study_modes(@course)

          render :edit
        end
      end

    private

      def study_mode_params
        params.require(:provider_interface_offer_wizard).permit(:study_mode)
      end

      def available_study_modes(course)
        GetChangeOfferOptions.new(
          user: current_provider_user,
          current_course: @application_choice.offered_course,
        ).available_study_modes(course: course)
      end

      def attributes_for_wizard
        study_mode_params.to_h.merge!(current_step: 'study_modes')
      end
    end
  end
end
