module CandidateInterface
  module CourseChoices
    class ReviewDegreeGradeInterruptionController < CandidateInterface::CourseChoices::BaseController
      before_action :redirect_to_your_applications_if_submitted

      def show
        @application_choice = current_application.application_choices.find(params[:application_choice_id])
        @required_grade = course_degree_requirement_text
        @candidate_highest_grade = highest_degree_grade
        @continue_path = ReviewInterruptionPathDecider.decide_path(@application_choice, current_step: :grade_incompatible)
      end

    private

      def course_degree_requirement_text
        {
          'two_one' => '2:1 or higher (or equivalent)',
          'two_two' => '2:2 or higher (or equivalent)',
          'third_class' => 'third-class or higher (or equivalent)',
          'not_required' => 'any grade',
        }[grade_evaluator.course_degree_requirement]
      end

      def highest_degree_grade
        {
          'First class honours' => 'first class honours',
          'First-class honours' => 'first-class honours',
          'Upper second-class honours (2:1)' => 'upper second-class honours (2:1)',
          'Lower second-class honours (2:2)' => 'lower second-class honours (2:2)',
          'Third-class honours' => 'third-class honours',
          'Pass' => 'pass',
        }[grade_evaluator.highest_degree_grade]
      end

      def grade_evaluator
        DegreeGradeEvaluator.new(@application_choice)
      end
    end
  end
end
