module CandidateInterface
  class CandidateInterfaceController < ActionController::Base
    include BasicAuthHelper
    include ParamsLogging
    before_action :add_params_to_request_store
    before_action :require_basic_auth_for_ui
    before_action :authenticate_candidate!
    before_action :add_candidate_id_to_log
    layout 'application'
    alias :audit_user :current_candidate

  private

    # controller-specific additional info to include in logstash logs
    def add_candidate_id_to_log
      RequestLocals.store[:candidate_id] = current_candidate.id if current_candidate
    end
  end
end
