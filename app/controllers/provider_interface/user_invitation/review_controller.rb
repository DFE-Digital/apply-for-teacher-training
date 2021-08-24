module ProviderInterface
  module UserInvitation
    class ReviewController < BaseController
      def check
        @wizard = InviteUserWizard.new(invite_user_store)
      end
    end
  end
end
