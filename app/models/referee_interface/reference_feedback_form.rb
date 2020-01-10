module RefereeInterface
  class ReferenceFeedbackForm
    include ActiveModel::Validations

    attr_reader :reference, :feedback
    validates :feedback, presence: true, word_count: { maximum: 300 }

    def initialize(reference:, feedback: nil)
      @reference = reference
      @feedback = feedback
    end

    def save
      return unless valid?

      ActiveRecord::Base.transaction do
        reference.update!(feedback: feedback, feedback_status: 'feedback_provided')

        # If all of the references have been provided we need to change the
        # state of the application choices
        if reference.application_form.application_references_complete?
          reference.application_form.application_choices.includes(:course_option).find_each do |application_choice|
            ApplicationStateChange.new(application_choice).references_complete!
          end
        end
      end

      true
    end
  end
end
