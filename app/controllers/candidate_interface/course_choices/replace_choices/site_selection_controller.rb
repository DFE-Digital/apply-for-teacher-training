module CandidateInterface
  module CourseChoices
    module ReplaceChoices
      class SiteSelectionController < BaseController
        def replace_location
          @course_choice = current_application.application_choices.find(params['id'])
          @pick_site = PickSiteForm.new(
            application_form: current_application,
            provider_id: @course_choice.provider.id,
            course_id: @course_choice.course.id,
            study_mode: @course_choice.course_option.study_mode,
            course_option_id: @course_choice.course_option.id,
          )
        end

        def validate_location
          @course_choice = current_application.application_choices.find(params['id'])
          @replacement_course_option_id = params.dig('candidate_interface_pick_site_form', 'course_option_id')

          @pick_site = PickSiteForm.new(
            application_form: current_application,
            provider_id: @course_choice.provider.id,
            course_id: @course_choice.course.id,
            study_mode: @course_choice.course_option.study_mode,
            course_option_id: @replacement_course_option_id,
          )

          if @pick_site.valid?
            redirect_to candidate_interface_confirm_replacement_course_choice_path(@course_choice.id, @replacement_course_option_id)
          else
            flash[:warning] = 'Please select a new location.'
            redirect_to candidate_interface_replace_course_choice_location_path(@course_choice.id)
          end
        end
      end
    end
  end
end
