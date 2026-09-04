module CandidateInterface
  module Steps
    class CourseSelectionWizard::CourseStudyMode
      include DfE::Wizard::Step

      delegate :provider, :provider_exists?, :multiple_sites?, to: :wizard

      attribute :study_mode

      validates :study_mode, presence: true

      def self.permitted_params
        %i[study_mode]
      end

      def completed?
        !multiple_sites?
      end
    end
  end
end
