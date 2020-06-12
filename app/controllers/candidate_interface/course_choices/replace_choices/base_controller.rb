module CandidateInterface
  module CourseChoices
    module ReplaceChoices
      class BaseController < CandidateInterfaceController
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

        def confirm_choice
          @course_choice = current_application.application_choices.find(params['id'])
          @replacement_course_option = CourseOption.find(params['course_option_id'])
        end

        def update_choice
          @course_choice = current_application.application_choices.find(params['id'])
          @replacement_course_option_id = params['course_option_id']

          @pick_site = PickSiteForm.new(
            application_form: current_application,
            provider_id: @course_choice.provider.id,
            course_id: @course_choice.course.id,
            study_mode: @course_choice.course_option.study_mode,
            course_option_id: @replacement_course_option_id,
          )

          if @pick_site.valid?
            @course_choice.update!(course_option_id: @replacement_course_option_id)
            flash[:success] = 'Your application has been updated'

            redirect_to candidate_interface_application_complete_path
          else
            flash[:warning] = 'Please select a new location.'
            redirect_to candidate_interface_replace_course_choice_location_path(@course_choice.id)
          end
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
end
