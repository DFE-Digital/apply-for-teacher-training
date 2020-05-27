module ProviderInterface
  module ChangeOffer
    class ChangeCourseComponent < ViewComponent::Base
      include ViewHelper

      attr_reader :change_offer_form, :application_choice

      def initialize(change_offer_form:)
        @change_offer_form = change_offer_form
        @application_choice = change_offer_form.application_choice

        if @change_offer_form.valid?
          @change_offer_form.step = @change_offer_form.next_step
        end
      end

      def courses
        Course.where(
          open_on_apply: true,
          provider_id: change_offer_form.provider_id,
          study_mode: study_mode_for_courses,
        ).order(:name)
      end

      def study_mode_for_courses
        current_study_mode = application_choice.offered_option.study_mode
        [current_study_mode, :full_time_or_part_time]
      end

      def page_title
        if application_choice.offer? && change_offer_form.entry == :course
          'Change course'
        else
          'Select alternative course'
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
