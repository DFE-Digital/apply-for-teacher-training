module CandidateInterface
  class ErrorsController < CandidateInterfaceController
    skip_before_action :verify_authenticity_token
    skip_before_action :authenticate_candidate!
    allow_unauthenticated_access only: [:wrong_email_address]

    def account_locked
      render 'errors/account_locked', status: :forbidden, formats: :html
    end

    def not_found
      render 'errors/not_found', status: :not_found, formats: :html
    end

    def wrong_email_address
      render 'errors/wrong_email_address_used_for_candidate', status: :forbidden, formats: :html
    end
  end
end
