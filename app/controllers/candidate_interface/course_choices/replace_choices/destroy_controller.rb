module CandidateInterface
  module CourseChoices
    module ReplaceChoices
      class DestroyController < BaseController
        def confirm_destroy
          @course_choice = current_application.application_choices.find(params['id'])
        end

        def destroy
          @course_choice = current_application.application_choices.find(params['id'])
          @course_choice.destroy
          flash[:success] = 'Your application has been updated'

          if current_application.course_choices_that_need_replacing.any?
            redirect_to candidate_interface_replace_course_choices_path
          else
            redirect_to candidate_interface_application_complete_path
          end
        end
      end
    end
  end
end
