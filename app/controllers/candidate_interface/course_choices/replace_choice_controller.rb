module CandidateInterface
  module CourseChoices
    class ReplaceChoiceController < BaseController
      skip_before_action :redirect_to_dashboard_if_submitted
      before_action :render_404_if_flag_is_inactive

      def pick_choice_to_replace
        if only_one_course_choice_needs_replacing?
          redirect_to candidate_interface_replace_course_choice_path(
            current_application.course_choices_that_need_replacing.first.id,
          ) and return
        end

        @pick_choice_to_replace = PickChoiceToReplaceForm.new
        @choices = current_application.course_choices_that_need_replacing
      end

      def picked_choice
        @pick_choice_to_replace = PickChoiceToReplaceForm.new(pick_choice_to_replace_params)

        if @pick_choice_to_replace.valid?
          redirect_to candidate_interface_replace_course_choice_path(@pick_choice_to_replace.id)
        else
          @pick_choice_to_replace = PickChoiceToReplaceForm.new
          @choices = current_application.course_choices_that_need_replacing

          render :select_choice
        end
      end

      def show; end

    private

      def render_404_if_flag_is_inactive
        render_404 and return unless FeatureFlag.active?('replace_full_or_withdrawn_application_choices')
      end

      def only_one_course_choice_needs_replacing?
        current_application.course_choices_that_need_replacing.any? && current_application.course_choices_that_need_replacing.count == 1
      end

      def pick_choice_to_replace_params
        params.require(:candidate_interface_pick_choice_to_replace_form).permit(:id)
      end
    end
  end
end
