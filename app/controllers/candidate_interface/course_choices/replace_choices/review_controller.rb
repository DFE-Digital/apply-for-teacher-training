module CandidateInterface
  module CourseChoices
    module ReplaceChoices
      class ReviewController < BaseController
        def confirm_choice
          @course_choice = current_application.application_choices.find(params['id'])
          @replacement_course_option = CourseOption.find(params['course_option_id'])
        end

        def update_choice
          @course_choice = current_application.application_choices.find(params['id'])
          @replacement_course_option_id = params['course_option_id']
          @pick_site = create_pick_site_form(@course_choice, @replacement_course_option_id)

          if @pick_site.valid?
            @course_choice.update!(course_option_id: @replacement_course_option_id)
            flash[:success] = 'Your application has been successfully updated.'

            redirect_to candidate_interface_application_complete_path
          else
            flash[:warning] = 'Please select a new location.'
            redirect_to candidate_interface_replace_course_choice_update_location_path(@course_choice.id)
          end
        end
      end
    end
  end
end
