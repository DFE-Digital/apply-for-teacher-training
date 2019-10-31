module CandidateInterface
  class WorkExplanationForm
    include ActiveModel::Model

    attr_accessor :work_history_explanation

    validates :work_history_explanation, presence: true
    validates :work_history_explanation, word_count: { maximum: 600 }

    def self.build_from_application(application_form)
      new(
        work_history_explanation: application_form.work_history_explanation,
      )
    end

    def save(application_form)
      return false unless valid?

      application_form.update!(
        work_history_explanation: work_history_explanation,
      )
    end
  end
end
