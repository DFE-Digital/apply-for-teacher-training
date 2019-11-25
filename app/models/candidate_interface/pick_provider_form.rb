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
        Course.includes(:provider).visible_to_candidates.map(&:provider).uniq.sort_by(&:name)
      end
    end
  end
end
