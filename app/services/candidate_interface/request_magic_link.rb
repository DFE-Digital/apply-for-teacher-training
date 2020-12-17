module CandidateInterface
  class RequestMagicLink
    def self.for_sign_in(candidate:)
      magic_link_token = candidate.create_magic_link_token!
      AuthenticationMailer.sign_in_email(candidate: candidate, token: magic_link_token).deliver_later
    end

    def self.for_sign_up(candidate:)
      magic_link_token = candidate.create_magic_link_token!
      AuthenticationMailer.sign_up_email(candidate: candidate, token: magic_link_token).deliver_later
      StateChangeNotifier.sign_up(candidate)
    end
  end
end
