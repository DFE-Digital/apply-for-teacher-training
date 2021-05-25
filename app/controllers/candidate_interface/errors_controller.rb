module CandidateInterface
  class ErrorsController < CandidateInterfaceController
    skip_before_action :verify_authenticity_token
    skip_before_action :authenticate_candidate!

    def not_found
      render 'errors/not_found', status: :not_found, formats: :html
    end
  end
end
