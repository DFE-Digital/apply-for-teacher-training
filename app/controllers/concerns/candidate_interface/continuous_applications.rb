# frozen_string_literal: true

module CandidateInterface
  module ContinuousApplications
    extend ActiveSupport::Concern

    included do
      # CandidateInterfaceController
      before_action :redirect_to_post_offer_dashboard_if_accepted_deferred_or_recruited
      before_action CarryOverFilter
    end
  end
end
