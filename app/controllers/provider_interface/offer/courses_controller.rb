module ProviderInterface
  module Offer
    class CoursesController < ProviderInterface::OffersController
      def new
        @wizard = OfferWizard.new(offer_store, {current_step: 'course'})
        @wizard.save_state!
        set_courses

        # if logic is on wizard
        if @courses.length == 1
          @wizard = OfferWizard.new(offer_store, course_id: @courses.first.id)
          return redirect_to [:new , :provider_interface, :offer, @wizard.next_step] # where next step is sites
        end
      end

      def create
        @wizard = OfferWizard.new(offer_store, course_id: course_params[:course_id])

        @wizard.save_state!

        if @wizard.valid?
          return redirect_to [:new , :provider_interface, :offer, @wizard.next_step]
        else
          set_courses
          render 'new'
        end
      end

      private

      def course_params
        course_params = params[:provider_interface_offer_wizard] || ActionController::Parameters.new
        course_params.permit(:course_id)
      end

      def set_courses
        @courses = Course.where(
          open_on_apply: true,
          provider_id: @wizard.provider_id,
          # is recruitment cycle year something that we should consider storing on our wizard on entry
          # so we are not required to retrieve information back from database or rely on checking the
          # offered courses option?
          recruitment_cycle_year: @wizard.course_option.course.recruitment_cycle_year,
        ).order(:name)
      end
    end
  end
end
