module CandidateInterface
  class Reference::RefereeTypeForm
    include ActiveModel::Model

    attr_accessor :referee_type

    validates :referee_type, presence: true

    def self.build_from_reference(reference)
      new(referee_type: reference.present? ? reference.referee_type.dasherize : nil)
    end

    def update(reference)
      return false unless valid?

      reference.update!(referee_type:)
    end
  end
end
