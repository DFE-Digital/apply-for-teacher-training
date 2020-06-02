module ProviderInterface
  module ChangeOffer
    class ChangeStudyModeComponent < ViewComponent::Base
      include ViewHelper

      attr_reader :change_offer_form, :application_choice, :providers

      def initialize(change_offer_form:)
        @change_offer_form = change_offer_form
        @application_choice = change_offer_form.application_choice
        @providers = providers

        if @change_offer_form.valid?
          @change_offer_form.step = @change_offer_form.next_step
        end
      end

      def study_modes
        %w[full_time part_time]
      end

      def course
        Course.find change_offer_form.course_id
      end

      def page_title
        if application_choice.offer? && change_offer_form.entry == :study_mode
          'Change to full time or part time'
        else
          'Select full time or part time'
        end
      end

      def next_step_url
        request.params[:step] = change_offer_form.step
        request.params
      end

      def next_step_method
        :get
      end
    end
  end
end
