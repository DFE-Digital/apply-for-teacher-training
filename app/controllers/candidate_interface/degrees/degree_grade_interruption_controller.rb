module CandidateInterface
  module Degrees
    class DegreeGradeInterruptionController < BaseController
      ORDERED_REQUIRED_GRADES = {
        two_one: 4,
        two_two: 3,
        third_class: 2,
        not_required: 1,
      }.freeze

      def show
        @highest_required_grade = highest_required_grade
        @highest_candidate_grade = highest_candidate_grade_key
        @multiple_application_choices = current_application.application_choices.unsubmitted.count
      end

    private

      def highest_required_grade
        current_application.application_choices
          .unsubmitted
          .select { |choice| DegreeGradeEvaluator.new(choice).degree_grade_below_required_grade? }
          .max_by { |choice| ORDERED_REQUIRED_GRADES[choice.course.degree_grade.to_sym] }
          &.course
          &.degree_grade
      end

      def highest_candidate_grade_key
        {
          'First class honours' => 'first_class_honours',
          'First-class honours' => 'first_class_honours',
          'Upper second-class honours (2:1)' => 'upper_second_class_honours',
          'Lower second-class honours (2:2)' => 'lower_second_class_honours',
          'Third-class honours' => 'third_class_honours',
          'Pass' => 'pass',
        }[highest_candidate_grade]
      end

      def highest_candidate_grade
        choice = current_application.application_choices.first

        DegreeGradeEvaluator.new(choice).highest_degree_grade
      end
    end
  end
end
