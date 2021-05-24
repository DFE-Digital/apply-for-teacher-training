module SupportInterface
  module ValidationErrors
    class ProviderController < SupportInterface::ValidationErrors::UserController
      before_action :set_user_type

      def service_scope
        :manage
      end

    private

      def set_user_type
        @user_type = :provider
      end
    end
  end
end
