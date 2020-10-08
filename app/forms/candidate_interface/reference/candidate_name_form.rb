module CandidateInterface
  class Reference::CandidateNameForm
    include ActiveModel::Model

    attr_accessor :first_name, :last_name

    validates :first_name, presence: true
    validates :last_name, presence: true

    def self.build_from_reference(reference)
      new(
        first_name: reference.application_form.first_name,
        last_name: reference.application_form.last_name,
      )
    end

    def save(reference)
      return false unless valid?

      reference.application_form.update!(
        first_name: first_name,
        last_name: last_name,
      )
    end
  end
end
