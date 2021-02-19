module CandidateInterface
  module RestructuredWorkHistory
    class ChoiceForm
      include ActiveModel::Model

      attr_accessor :choice, :explanation

      validates :choice, presence: true
      validates :explanation, presence: true, if: -> { can_not_complete_work_history? }
      validates :explanation, word_count: { maximum: 400 }

      def save(application_form)
        return false unless valid?

        application_form.update!(
          work_history_status: choice,
          work_history_explanation: can_not_complete_work_history? ? explanation : nil,
        )
      end

      def self.build_from_application(application_form)
        new(
          choice: application_form.work_history_status,
          explanation: application_form.work_history_explanation,
        )
      end

      def can_complete_work_history?
        choice == 'can_complete'
      end

      def can_not_complete_work_history?
        choice == 'can_not_complete'
      end
    end
  end
end
