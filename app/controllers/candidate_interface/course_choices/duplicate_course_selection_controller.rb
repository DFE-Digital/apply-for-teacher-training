module CandidateInterface
  module CourseChoices
    class DuplicateCourseSelectionController < CandidateInterface::CourseChoices::BaseController
      before_action :set_course
      before_action :set_backlink, only: [:new] # rubocop:disable Rails/LexicallyScopedActionFilter
      skip_before_action :redirect_to_your_applications_if_maximum_amount_of_choices_have_been_used

    private

      def current_step
        :duplicate_course_selection
      end

      def set_course
        @course = @wizard.course || Course.find(params[:course_id])
      end

      def set_backlink
        @backlink = if request.referer.blank?
                      candidate_interface_application_choices_path
                    elsif @wizard.previous_step.present?
                      @wizard.previous_step_path
                    elsif @wizard.application_choice
                      candidate_interface_edit_course_choices_which_course_are_you_applying_to_path(
                        application_choice_id: @wizard.application_choice.id,
                      )
                    else
                      candidate_interface_course_choices_which_course_are_you_applying_to_path(
                        provider_id: @wizard.provider.id,
                      )
                    end
      end

      def wizard_controller?
        true
      end
    end
  end
end
