module ProviderInterface
  module Offer
    class ChecksController < OffersController
      def new
        @wizard = OfferWizard.new(offer_store, { current_step: 'check', action: })
        @wizard.save_state!

        @providers = available_providers
        @courses = available_courses(@wizard.provider_id)
        @interview_cancellation_presenter = InterviewCancellationExplanationPresenter.new(@application_choice)
        @course_options = available_course_options(@wizard.course_id, @wizard.study_mode)
      end

      def edit
        @wizard = OfferWizard.new(offer_store, { current_step: 'check', action: })
        @wizard.save_state!

        @providers = available_providers
        @courses = available_courses(@wizard.provider_id)
        @course_options = available_course_options(@wizard.course_id, @wizard.study_mode)
      end
    end
  end
end
