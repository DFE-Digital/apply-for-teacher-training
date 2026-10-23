module SupportInterface
  module ValidationErrors
    class ProviderController < SupportInterface::ValidationErrors::UserController
      before_action :authorize_support_user
      before_action :set_user_type

      def service_scope
        :manage
      end

    private

      def authorize_support_user
        authorize(nil, :show?, policy_class: SupportInterface::ProviderUserPolicy)
      end

      def set_user_type
        @user_type = :provider
      end
    end
  end
end
