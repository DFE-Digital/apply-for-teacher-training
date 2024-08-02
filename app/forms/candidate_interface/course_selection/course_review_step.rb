module CandidateInterface
  module CourseSelection
    class CourseReviewStep < DfE::Wizard::Step
      def self.route_name
        'candidate_interface_continuous_applications_course_review'
      end

      def next_step; end
    end
  end
end
