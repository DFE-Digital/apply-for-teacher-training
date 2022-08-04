module CandidateInterface
  class SectionCompleteForm
    include ActiveModel::Model

    attr_accessor :completed
    validates :completed, presence: true
    validates :completed, inclusion: { in: %w[true false] }

    def save(application_form, attr)
      return false unless valid?

      application_form.update!(attr => completed)
    end

    def completed?
      ActiveModel::Type::Boolean.new.cast(completed)
    end

    def not_completed?
      !completed?
    end
  end
end
