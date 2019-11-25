module CandidateInterface
  class PickProviderForm
    include ActiveModel::Model

    attr_accessor :code
    validates :code, presence: true

    def other?
      code == 'other'
    end

    def available_providers
      # TODO: Remove when the QA environment no longer has the "Example provider" stored
      Provider.where.not(name: 'Example provider').order(:name)
    end
  end
end
