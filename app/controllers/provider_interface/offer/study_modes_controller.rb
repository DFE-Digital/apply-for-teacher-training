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
        @wizard = OfferWizard.new(offer_store, study_mode_params.to_h)
        @wizard.course_option_id = nil if @wizard.course_option_id && @wizard.course_option.study_mode != @wizard.study_mode

        if @wizard.valid_for_current_step?
          @wizard.save_state!

          redirect_to [:new, :provider_interface, @application_choice, :offer, @wizard.next_step]
        else
          @course = Course.find(@wizard.course_id)
          @study_modes = avalable_study_modes(@course)

          render :new
        end
      end

    private

      def study_mode_params
        params.require(:provider_interface_offer_wizard).permit(:study_mode)
      end

      def available_study_modes(course)
        course.available_study_modes_from_options.map do |study_mode|
          Struct.new(:id, :value).new(study_mode, study_mode.humanize)
        end
      end
    end
  end
end
