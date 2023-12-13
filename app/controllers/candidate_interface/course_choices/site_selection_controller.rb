module CandidateInterface
  module CourseChoices
    class SiteSelectionController < BaseController
      def new
        @pick_site = PickSiteForm.new
      end

      def edit
        @course_choice_id = params[:course_choice_id]
        current_application_choice = current_application.application_choices.find(@course_choice_id)

        @pick_site = PickSiteForm.new(
          course_option_id: current_application_choice.course_option_id.to_s,
        )

        @return_to = return_to_after_edit(default: candidate_interface_course_choices_review_path)
        @application_review = params['return-to'] || params[:return_to]

        @return_to_path = candidate_interface_edit_course_choices_course_path(course_choice_id: @course_choice_id, return_to: @application_review)
      end

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

    private

      def available_sites
        PickSiteForm.available_sites(params.fetch(:course_id), params.fetch(:study_mode))
      end
      helper_method :available_sites
    end
  end
end
