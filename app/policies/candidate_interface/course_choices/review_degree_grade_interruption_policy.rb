module CandidateInterface
  module CourseChoices
    class ReviewDegreeGradeInterruptionPolicy < ApplicationPolicy
      def show?
        DegreeGradeEvaluator.new(record).degree_grade_below_required_grade?
      end
    end
  end
end
