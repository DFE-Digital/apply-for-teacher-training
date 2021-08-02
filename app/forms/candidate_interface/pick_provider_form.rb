module CandidateInterface
  class PickProviderForm
    include ActiveModel::Model

    attr_accessor :provider_id
    validates :provider_id, presence: true

    def courses_available?
      Course.current_cycle.exposed_in_find.where(provider_id: provider_id).present?
    end

    def available_providers
      @available_providers ||= Provider.all.order(:name)
    end
  end
end
