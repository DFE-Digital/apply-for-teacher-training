module CandidateInterface
  module CourseChoices
    class ReviewDegreeGradeInterruptionController < CandidateInterface::CourseChoices::BaseController
      before_action :redirect_to_your_applications_if_submitted
      after_action :verify_authorized
      after_action :verify_policy_scoped

      def show
        authorize @application_choice, :show?, policy_class: CandidateInterface::CourseChoices::ReviewDegreeGradeInterruptionPolicy

        @required_grade = course_degree_requirement_text
        @candidate_highest_grade = highest_degree_grade
        @continue_path = ReviewInterruptionPathDecider.decide_path(@application_choice, current_step: :grade_incompatible)
      end

    private

      def course_degree_requirement_text
        grade_evaluator.course_degree_requirement
      end

      def highest_degree_grade
        {
          'First class honours' => 'first_class_honours',
          'First-class honours' => 'first_class_honours',
          'Upper second-class honours (2:1)' => 'upper_second_class_honours',
          'Lower second-class honours (2:2)' => 'lower_second_class_honours',
          'Third-class honours' => 'third_class_honours',
          'Pass' => 'pass',
        }[grade_evaluator.highest_degree_grade]
      end

      def grade_evaluator
        DegreeGradeEvaluator.new(@application_choice)
      end

      def application_choice
        @application_choice ||= policy_scope(ApplicationChoice).find(params.expect(:application_choice_id))
      end
    end
  end
end
