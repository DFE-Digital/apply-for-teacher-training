module CandidateInterface
  module CourseChoices
    class SiteSelectionController < BaseController
      def create
        course_option_id = params.dig(:candidate_interface_pick_site_form, :course_option_id)

        @pick_site = PickSiteForm.new(
          application_form: current_application,
          course_option_id:,
        )

        render :new and return unless @pick_site.valid?

        AddOrUpdateCourseChoice
          .new(
            course_option_id:,
            application_form: current_application,
            controller: self,
            id_of_course_choice_to_replace: params[:course_choice_id],
          )
          .call
      end

      def update
        course_option_id = params.dig(:candidate_interface_pick_site_form, :course_option_id)
        @pick_site = PickSiteForm.new(
          application_form: current_application,
          course_option_id:,
        )

        render :new and return unless @pick_site.valid?

        AddOrUpdateCourseChoice
          .new(
            course_option_id:,
            application_form: current_application,
            controller: self,
            id_of_course_choice_to_replace: params[:course_choice_id],
            return_to: params[:return_to],
          )
          .call
      end
    end
  end
end
