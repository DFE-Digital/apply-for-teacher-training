module CandidateInterface
  class Reference::RefereeNameForm
    include ActiveModel::Model

    attr_accessor :name

    validates :name, presence: true, length: { minimum: 2, maximum: 200 }

    def self.build_from_reference(reference)
      new(name: reference.presence&.name)
    end

    def save(application_form, referee_type, reference: nil)
      return false unless valid?

      ApplicationForm.with_unsafe_application_choice_touches do
        if reference.present?
          reference.update!(referee_type:, name:)
        else
          application_form.application_references.create!(name:, referee_type:)
          application_form.update(references_completed: false)
        end
      end
    end

    def update(reference)
      return false unless valid?

      ApplicationForm.with_unsafe_application_choice_touches do
        reference.update!(name:)
      end
    end
  end
end
