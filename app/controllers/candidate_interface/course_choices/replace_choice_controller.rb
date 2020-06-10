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
          flash[:warning] = 'Please select a course choice to update.'

          render :pick_choice_to_replace
        end
      end

      def choose_action
        # @pick_replacement_action = PickReplacmentActionForm.new
        @course_choice = current_application.application_choices.find(params['id'])
        @pluralize_provider = 'provider'.pluralize(current_application.unique_provider_list.count)
        @course_name_and_code = @course_choice.course.name_and_code
        @provider_name = @course_choice.provider.name
        @site_name = @course_choice.site.name
      end

      def route_action
        binding.pry
      end

    private

      def render_404_if_flag_is_inactive
        render_404 and return unless FeatureFlag.active?('replace_full_or_withdrawn_application_choices')
      end

      def only_one_course_choice_needs_replacing?
        current_application.course_choices_that_need_replacing.any? && current_application.course_choices_that_need_replacing.count == 1
      end

      def pick_choice_to_replace_params
        return nil unless params.key?(:candidate_interface_pick_choice_to_replace_form)

        params.require(:candidate_interface_pick_choice_to_replace_form).permit(:id)
      end
    end
  end
end
