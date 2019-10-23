module CandidateInterface
  class CandidateInterfaceController < ActionController::Base
    include BasicAuthHelper
    before_action :require_basic_auth_for_ui
    before_action :authenticate_candidate!
    layout 'application'

    alias :current_user :current_candidate
  end
end
