module CandidateInterface
  module CourseChoices
    class ReviewDegreeGradeInterruptionController < CandidateInterface::CourseChoices::BaseController
      before_action :redirect_to_your_applications_if_submitted

      def show
        @application_choice = current_application.application_choices.find(params[:application_choice_id])
        @required_grade = required_course_degree_text
        @candidate_highest_grade = highest_degree_grade
        @continue_path = ReviewInterruptionPathDecider.decide_path(@application_choice, current_step: :grade_incompatible)
      end

    private

      def required_course_degree_text
        grade_evaluator.required_course_degree_text
      end

      def highest_degree_grade
        grade_evaluator.highest_degree_grade
      end

      def grade_evaluator
        DegreeGradeEvaluator.new(@application_choice)
      end
    end
  end
end
