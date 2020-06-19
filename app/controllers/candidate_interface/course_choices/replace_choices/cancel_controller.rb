module CandidateInterface
  module CourseChoices
    module ReplaceChoices
      class CancelController < BaseController
        def confirm_cancel
          @course_choice = current_application.application_choices.find(params['id'])
        end

        def cancel
          redirect_to candidate_interface_confirm_withdraw_full_course_choice_path(params['id']) and return if only_one_course_choice_needs_replacing?

          @course_choice = current_application.application_choices.find(params['id'])
          ApplicationStateChange.new(@course_choice).cancel!
          flash[:success] = 'Your application has been successfully updated.'

          if current_application.course_choices_that_need_replacing.any?
            redirect_to candidate_interface_replace_course_choices_path
          else
            redirect_to candidate_interface_application_complete_path
          end
        end

        def confirm_withdraw
          @course_choice = current_application.application_choices.find(params['id'])
        end

        def withdraw
          @course_choice = current_application.application_choices.find(params['id'])
          ApplicationStateChange.new(@course_choice).cancel!
          flash[:notice] = 'Your application has been withdrawn.'

          redirect_to candidate_interface_application_complete_path
        end
      end
    end
  end
end
