module CandidateInterface
  module Steps
    class CourseSelectionWizard::FindCourseSelection
      include DfE::Wizard::Step

      attribute :confirm

      validates :confirm, presence: true

      delegate :multiple_study_modes?, :multiple_sites?, to: :wizard
      delegate :find_url, :provider, :name_and_code, to: :course, prefix: true

      def self.permitted_params
        %i[confirm]
      end

      def course_id
        wizard.state_store.course_id
      end

      def course
        Course.find(course_id)
      end

      def completed?
        confirm_answer? && !multiple_study_modes? && !multiple_sites?
      end

      def confirm_answer?
        ActiveModel::Type::Boolean.new.cast(confirm).present?
      end
    end
  end
end
