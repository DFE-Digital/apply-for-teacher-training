module CandidateInterface
  module CourseChoices
    class PersonalStatementController < BaseController
      def new; end

      def edit; end

      def create
          course_option = @pick_course.available_course_options.first 
          AddOrUpdateCourseChoice.new( 
            course_option_id: course_option.id,
            application_form: current_application,
            personal_statement: personal_statement,
            controller: self,
            id_of_course_choice_to_replace: params[:course_choice_id],
          ).call
      end

      def update; end
    end
  end
end
