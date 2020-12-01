module CandidateInterface
  class FindFeedbackForm
    include ActiveModel::Model

    attr_accessor :path, :original_controller, :feedback,
                  :email_address, :hidden_feedback_field

    validates :path, :original_controller, :feedback, presence: true
    validates :hidden_feedback_field, absence: true
    validates :email_address, email_address: true, allow_blank: true

    def save
      return false unless valid?

      FindFeedback.create!(
        path: path,
        original_controller: original_controller,
        feedback: feedback,
        email_address: email_address,
      )
    end
  end
end
