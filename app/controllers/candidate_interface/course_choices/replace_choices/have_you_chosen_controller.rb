module CandidateInterface
  module CourseChoices
    module ReplaceChoices
      class HaveYouChosenController < BaseController
        def ask
          @course_choice = current_application.application_choices.find(params[:id])
          @choice_form = CandidateInterface::CourseChosenForm.new
        end

        def decide
          @course_choice = current_application.application_choices.find(params[:id])
          @choice_form = CandidateInterface::CourseChosenForm.new(application_choice_params)
          render :ask and return unless @choice_form.valid?

          if @choice_form.chosen_a_course?
            redirect_to candidate_interface_replace_course_choice_provider_path(@course_choice.id)
          else
            redirect_to candidate_interface_replace_go_to_find_path(@course_choice.id)
          end
        end

        def go_to_find
          @course_choice = current_application.application_choices.find(params[:id])
        end

      private

        def application_choice_params
          params.fetch(:candidate_interface_course_chosen_form, {}).permit(:choice)
        end
      end
    end
  end
end
