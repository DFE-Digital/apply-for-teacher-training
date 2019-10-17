module CandidateInterface
  class CandidateInterfaceController < ActionController::Base
    before_action :authenticate_candidate!

    layout 'application'
  end
end
