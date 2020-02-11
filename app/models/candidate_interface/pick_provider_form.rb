module CandidateInterface
  class PickProviderForm
    include ActiveModel::Model

    attr_accessor :code
    validates :code, presence: true

    def other?
      Course.exposed_in_find.pluck(:provider_id).exclude?(Provider.find_by(code: code).id)
    end

    def available_providers
      @available_providers ||= begin
        Provider.all.order(:name)
      end
    end
  end
end
