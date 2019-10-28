module CandidateInterface
  class CandidateInterfaceController < ActionController::Base
    include BasicAuthHelper
    before_action :require_basic_auth_for_ui
    before_action :authenticate_candidate!
    layout 'application'
    alias :audit_user :current_candidate

  private

    # contoller-specific additional info to included in lograge/logstash logs
    def append_info_to_payload(payload)
      super
      payload[:candidate_id] = current_candidate.id if current_candidate
    end
  end
end
