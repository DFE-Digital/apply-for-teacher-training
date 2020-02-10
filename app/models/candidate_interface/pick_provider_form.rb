module CandidateInterface
  class PickProviderForm
    include ActiveModel::Model

    attr_accessor :code
    validates :code, presence: true

    def other?
      code == 'other'
    end

    def available_providers
      @available_providers ||= begin
        Provider.all.order(:name)
      end
    end
  end
end
