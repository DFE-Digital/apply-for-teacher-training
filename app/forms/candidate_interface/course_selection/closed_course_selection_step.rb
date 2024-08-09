module CandidateInterface
  module CourseSelection
    class ClosedCourseSelectionStep < DfE::Wizard::Step
      include CandidateInterface::Concerns::CourseSelectionStepHelper
      attr_accessor :provider_id, :course_id
      validates :provider_id, :course_id, presence: true

      def self.route_name
        'candidate_interface_course_choices_closed_course_selection'
      end

      def self.permitted_params
        %i[provider_id course_id]
      end

      def previous_step
        :which_course_are_you_applying_to
      end

      def next_step; end

      def previous_step_path_arguments
        { provider_id: provider_id }
      end
    end
  end
end
