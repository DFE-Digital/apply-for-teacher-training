module CandidateInterface
  class RequestMagicLinkSignup
    def self.call(candidate:)
      magic_link_token = candidate.create_magic_link_token!
      AuthenticationMailer.sign_up_email(candidate: candidate, token: magic_link_token).deliver_later
      StateChangeNotifier.sign_up(candidate)
    end
  end
end
