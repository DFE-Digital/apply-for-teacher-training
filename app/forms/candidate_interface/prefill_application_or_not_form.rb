module CandidateInterface
  class PrefillApplicationOrNotForm
    include ActiveModel::Model

    attr_accessor :prefill

    validates :prefill, presence: true

    def prefill?
      ActiveModel::Type::Boolean.new.cast(prefill)
    end
  end
end
