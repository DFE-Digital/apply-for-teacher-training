module SupportInterface
  module ValidationErrors
    class CandidateController < SupportInterface::ValidationErrors::UserController
      before_action :authorize_support_user
      before_action :set_user_type

      def service_scope
        :apply
      end

    private

      def authorize_support_user
        authorize(nil, :show?, policy_class: SupportInterface::CandidatePolicy)
      end

      def set_user_type
        @user_type = :candidate
      end
    end
  end
end
