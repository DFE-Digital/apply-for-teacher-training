module RefereeInterface
  class ConfidentialityForm
    include ActiveModel::Model

    attr_accessor :confidential

    validates :confidential, presence: true

    def self.build_from_reference(reference:)
      confidential = reference.confidential
      new(confidential: confidential)
    end

    def save(application_reference)
      return false unless valid?

      confidential_boolean = ActiveModel::Type::Boolean.new.cast(confidential)

      ApplicationForm.with_unsafe_application_choice_touches do
        application_reference.update!(
          confidential: confidential_boolean,
        )
      end
    end
  end
end
