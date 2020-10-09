module CandidateInterface
  class Reference::RefereeNameForm
    include ActiveModel::Model

    attr_accessor :name

    validates :name, presence: true, length: { minimum: 2, maximum: 200 }

    def self.build_from_reference(reference)
      new(name: reference.name)
    end

    def save(reference)
      return false unless valid?

      reference.update!(name: name)
    end
  end
end
