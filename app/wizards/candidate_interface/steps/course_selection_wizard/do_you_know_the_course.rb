module CandidateInterface
  module Steps
    class CourseSelectionWizard::DoYouKnowTheCourse
      include DfE::Wizard::Step

      attribute :answer, :string
      validates :answer, presence: true

      def self.permitted_params
        [:answer]
      end
    end
  end
end
