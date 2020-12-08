module CandidateInterface
  class RequestMagicLink
    def self.call(candidate:)
      magic_link_token = candidate.create_magic_link_token!
      AuthenticationMailer.sign_in_email(candidate: candidate, token: magic_link_token).deliver_later
    end
  end
end
