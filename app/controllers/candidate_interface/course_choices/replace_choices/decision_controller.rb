module CandidateInterface
  module CourseChoices
    module ReplaceChoices
      class DecisionController < BaseController
        def choose_action
          @pick_replacement_action = PickReplacementActionForm.new
          @course_choice = current_application.application_choices.find(params['id'])
          @pluralize_provider = 'provider'.pluralize(current_application.unique_provider_list.count)
          @course_name_and_code = @course_choice.course.name_and_code
          @provider_name = @course_choice.provider.name
          @site_name = @course_choice.site.name
        end

        def route_action
          @pick_replacement_action = PickReplacementActionForm.new(replacement_action_params)
          @course_choice = current_application.application_choices.find(params['id'])

          if @pick_replacement_action.valid? && @pick_replacement_action.replacement_action == 'replace_location'
            redirect_to candidate_interface_replace_course_choice_location_path(@course_choice.id)
          elsif !@pick_replacement_action.valid?
            flash[:warning] = 'Please select an option to update your course choice.'

            redirect_to candidate_interface_replace_course_choice_path(@course_choice.id)
          else
            render :contact_support
          end
        end

      private

        def replacement_action_params
          return nil unless params.key?(:candidate_interface_pick_replacement_action_form)

          params.require(:candidate_interface_pick_replacement_action_form).permit(:replacement_action)
        end
      end
    end
  end
end
