module CandidateInterface
  class RequestMagicLink
    def self.for_sign_in(candidate:, email_address:, path: nil)
      magic_link_token = candidate.create_magic_link_token!(path:)
      AuthenticationMailer.sign_in_email(candidate:, token: magic_link_token, email_address:).deliver_later
      magic_link_token
    end

    def self.for_sign_up(candidate:)
      magic_link_token = candidate.create_magic_link_token!
      AuthenticationMailer.sign_up_email(candidate:, token: magic_link_token).deliver_later
      StateChangeNotifier.sign_up(candidate)
      magic_link_token
    end
  end
end
