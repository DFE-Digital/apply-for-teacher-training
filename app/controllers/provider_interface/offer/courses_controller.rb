module ProviderInterface
  module Offer
    class CoursesController < OffersController
      def new
        @wizard = OfferWizard.new(offer_store, { decision: 'change_offer', current_step: 'courses', action: action })
        @wizard.save_state!

        @courses = available_courses(@wizard.provider_id)
      end

      def create
        @wizard = OfferWizard.new(offer_store, { decision: 'change_offer', current_step: 'courses' })
        reset_study_mode_if_course_has_changed_and_update_course

        if @wizard.valid_for_current_step?
          @wizard.save_state!

          redirect_to [:new, :provider_interface, @application_choice, :offer, @wizard.next_step]
        else
          @courses = available_courses(@wizard.provider_id)

          render :new
        end
      end

      def edit
        @wizard = OfferWizard.new(offer_store, { current_step: 'courses', action: action })
        @wizard.save_state!

        @courses = available_courses(@wizard.provider_id)
      end

      def update
        @wizard = OfferWizard.new(offer_store, { current_step: 'courses' })
        reset_study_mode_if_course_has_changed_and_update_course

        if @wizard.valid_for_current_step?
          @wizard.save_state!

          redirect_to [:edit, :provider_interface, @application_choice, :offer, @wizard.next_step]
        else
          @courses = available_courses(@wizard.provider_id)

          render :edit
        end
      end

    private

      def reset_study_mode_if_course_has_changed_and_update_course
        course_id = course_params['course_id']
        @wizard.study_mode = nil if course_id != @wizard.course_id
        @wizard.course_id = course_id
      end

      def course_params
        params.require(:provider_interface_offer_wizard).permit(:course_id)
      end
    end
  end
end
