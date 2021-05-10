module CandidateInterface
  class Reference::RefereeNameForm
    include ActiveModel::Model

    attr_accessor :name

    validates :name, presence: true, length: { minimum: 2, maximum: 200 }

    def self.build_from_reference(reference)
      new(name: reference.name)
    end

    def save(application_form, referee_type)
      return false unless valid?

      application_form.application_references.create!(name: name, referee_type: referee_type)
    end

    def update(reference)
      return false unless valid?

      reference.update!(name: name)
    end
  end
end
