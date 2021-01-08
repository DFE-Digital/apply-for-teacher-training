module CandidateInterface
  class RequestMagicLink
    def self.for_sign_in(candidate:, path: nil)
      magic_link_token = candidate.create_magic_link_token!(path: path)
      AuthenticationMailer.sign_in_email(candidate: candidate, token: magic_link_token).deliver_later
    end

    def self.for_sign_up(candidate:)
      magic_link_token = candidate.create_magic_link_token!
      AuthenticationMailer.sign_up_email(candidate: candidate, token: magic_link_token).deliver_later
      StateChangeNotifier.sign_up(candidate)
    end
  end
end
