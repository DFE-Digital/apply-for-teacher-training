module CandidateInterface
  module CourseChoices
    class PersonalStatementController < BaseController
      def new
        @personal_statement_form = PersonalStatementForm.new
      end

      def edit; end

      def create
        @personal_statement_form = PersonalStatementForm.new(
          personal_statement: params[:candidate_interface_personal_statement_form][:personal_statement],
          provider_id: params[:provider_id],
          course_id: params[:course_id],
          study_mode: params[:study_mode],
          site_id: params[:site_id],
        )

        course_option = @personal_statement_form.available_course_options.first
        AddOrUpdateCourseChoice.new(
          course_option_id: course_option.id,
          application_form: current_application,
          personal_statement: @personal_statement_form.personal_statement,
          controller: self,
          id_of_course_choice_to_replace: params[:course_choice_id],
        ).call
      end

      def update; end
    end
  end
end
