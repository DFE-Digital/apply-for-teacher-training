module RefereeInterface
  class RefuseFeedbackForm
    include ActiveModel::Model

    attr_accessor :refused

    validates :refused, presence: true

    def self.build_from_reference(reference:)
      refused = reference.refused ? 'yes' : 'no' unless reference.refused.nil?

      new(refused:)
    end

    def save(application_reference)
      return false unless valid?

      ApplicationForm.with_unsafe_application_choice_touches do
        application_reference.update!(
          refused: refused != 'no',
        )
      end
    end
  end
end
