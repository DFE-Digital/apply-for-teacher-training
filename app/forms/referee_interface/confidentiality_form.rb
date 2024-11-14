module RefereeInterface
  class ConfidentialityForm
    include ActiveModel::Model

    attr_accessor :is_confidential

    validates :is_confidential, presence: true

    def self.build_from_reference(reference:)
      is_confidential = reference.is_confidential ? true : false
      new(is_confidential: is_confidential)
    end

    def save(application_reference)
      return false unless valid?

      is_confidential_boolean = ActiveModel::Type::Boolean.new.cast(is_confidential)

      ApplicationForm.with_unsafe_application_choice_touches do
        application_reference.update!(
          is_confidential: is_confidential_boolean,
        )
      end
    end
  end
end
