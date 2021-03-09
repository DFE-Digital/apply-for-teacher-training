module TestHelpers
  module MailerSetupHelper
    def magic_link_stubbing(candidate)
      allow(candidate).to receive(:create_magic_link_token!).and_return('raw_token')
    end
  end
end
