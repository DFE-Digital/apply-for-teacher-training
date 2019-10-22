module CandidateInterface
  class CandidateInterfaceController < ActionController::Base
    include BasicAuthHelper
    before_action :blanket_basic_auth
    before_action :authenticate_candidate!
    layout 'application'
  end
end
