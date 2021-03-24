module CandidateInterface
  module CourseChoices
    class SiteSelectionController < BaseController
      def new
        candidate_is_updating_a_choice = params[:course_choice_id]
        @available_sites = PickSiteForm.available_sites(params.fetch(:course_id), params.fetch(:study_mode))

        if candidate_is_updating_a_choice
          @course_choice_id = params[:course_choice_id]
          current_application_choice = current_application.application_choices.find(@course_choice_id)

          @pick_site = PickSiteForm.new(
            course_option_id: current_application_choice.course_option_id.to_s,
          )
        else
          @pick_site = PickSiteForm.new
        end
      end

      def create
        course_option_id = params.dig(:candidate_interface_pick_site_form, :course_option_id)

        @pick_site = PickSiteForm.new(
          application_form: current_application,
          course_option_id: course_option_id,
        )

        render :new and return unless @pick_site.valid?

        AddOrUpdateCourseChoice
          .new(
            course_option_id,
            current_application,
            self,
            id_of_course_choice_to_replace: params[:course_choice_id],
          )
          .call
      end
    end
  end
end
