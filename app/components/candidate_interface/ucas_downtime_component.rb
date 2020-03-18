module CandidateInterface
  class UcasDowntimeComponent < ActionView::Component::Base
    def initialize; end

    def render?
      FeatureFlag.active?('banner_for_ucas_downtime')
    end
  end
end
