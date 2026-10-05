module CandidateInterface
  module Steps
    class CourseSelectionWizard::FindCourseSelection
      include DfE::Wizard::Step

      attribute :course_id
      attribute :confirm

      validates :course_id, presence: true
      validates :confirm, presence: true

      delegate :multiple_study_modes?, :multiple_sites?, to: :wizard
      delegate :find_url, :provider, :name_and_code, to: :course, prefix: true

      def self.permitted_params
        %i[course_id confirm]
      end

      def course
        Course.find(course_id)
      end

      def completed?
        confirm_answer? && !wizard.multiple_study_modes? && !wizard.multiple_sites? && valid_course_choice
      end

      def confirm_answer?
        ActiveModel::Type::Boolean.new.cast(confirm).present?
      end

      def valid_course_choice
        !wizard.duplicate_course? && !wizard.reapplication_limit_reached? && !wizard.course_unavailable? && !wizard.course_closed?
      end
    end
  end
end
