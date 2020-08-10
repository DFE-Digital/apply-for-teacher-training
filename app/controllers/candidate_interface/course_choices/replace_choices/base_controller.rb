module CandidateInterface
  module CourseChoices
    module ReplaceChoices
      class BaseController < CandidateInterfaceController
        before_action :redirect_to_dashboard_if_no_choices_need_replacing, :redirect_to_dashboard_if_find_is_down

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

      private

        def redirect_to_dashboard_if_no_choices_need_replacing
          redirect_to candidate_interface_application_complete_path if current_application.course_choices_that_need_replacing.blank?
        end

        def redirect_to_dashboard_if_find_is_down
          redirect_to candidate_interface_course_choices_review_path if EndOfCycleTimetable.find_down?
        end

        def only_one_course_choice_needs_replacing?
          current_application.course_choices_that_need_replacing.any? && current_application.course_choices_that_need_replacing.count == 1
        end

        def pick_choice_to_replace_params
          return nil unless params.key?(:candidate_interface_pick_choice_to_replace_form)

          params.require(:candidate_interface_pick_choice_to_replace_form).permit(:id)
        end

        def create_pick_site_form(course_choice, course_option_id)
          PickSiteForm.new(
            application_form: current_application,
            provider_id: course_choice.provider.id,
            course_id: course_choice.course.id,
            study_mode: course_choice.course_option.study_mode,
            course_option_id: course_option_id,
          )
        end
      end
    end
  end
end
