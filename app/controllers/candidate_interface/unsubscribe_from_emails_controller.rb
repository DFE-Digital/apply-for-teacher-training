module CandidateInterface
  class UnsubscribeFromEmailsController < CandidateInterfaceController
    skip_before_action :authenticate_candidate!, :set_user_context

    def unsubscribe
      candidate = Candidate.find_by_token_for!(:unsubscribe_link, token_param)
      candidate.update!(unsubscribed_from_emails: true)
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      render_404
    end

  private

    def token_param
      params.require(:token)
    end
  end
end
