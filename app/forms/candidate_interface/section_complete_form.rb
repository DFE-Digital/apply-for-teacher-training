module CandidateInterface
  class SectionCompleteForm
    include ActiveModel::Model

    attr_accessor :completed
    validates :completed, presence: true

    def save(application_form, attr)
      return false unless valid?

      application_form.update!(attr => completed)
    end
  end
end
