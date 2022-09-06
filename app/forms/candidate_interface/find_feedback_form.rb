module CandidateInterface
  class FindFeedbackForm
    include ActiveModel::Model

    attr_accessor :path, :find_controller, :feedback,
                  :email_address, :hidden_feedback_field

    validates :path, :find_controller, :feedback, presence: true
    validates :hidden_feedback_field, absence: true
    validates :email_address, valid_for_notify: true, allow_blank: true

    def save
      return false unless valid?

      FindFeedback.create!(
        path:,
        find_controller:,
        feedback:,
        email_address:,
      )
    end

    def arrived_from_page
      case find_controller
      when 'courses'
        'course'
      when 'results'
        'results'
      else
        'unknown'
      end
    end

    def user_is_a_bot?
      errors.key?(:hidden_feedback_field)
    end
  end
end
