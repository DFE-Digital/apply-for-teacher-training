module CandidateInterface
  module ContinuousApplications
    class WhichCourseAreYouApplyingToStep < DfE::WizardStep
      attr_accessor :course_id
      validates :course_id, presence: true

      def self.permitted_params
        [:course_id]
      end

      def next_step
        raise NotImplementedError, 'WhichCourseAreYouApplyingToStep#next_step has not been implemented'
      end
    end
  end
end
