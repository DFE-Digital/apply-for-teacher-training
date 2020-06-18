module CandidateInterface
  class WorkBreaksForm
    include ActiveModel::Model

    attr_accessor :work_history_breaks

    validates :work_history_breaks, presence: true
    validates :work_history_breaks, word_count: { maximum: 400 }

    def self.build_from_application(application_form)
      new(
        work_history_breaks: application_form.work_history_breaks,
      )
    end

    def save(application_form)
      return false unless valid?

      application_form.update!(
        work_history_breaks: work_history_breaks,
      )
    end
  end
end
