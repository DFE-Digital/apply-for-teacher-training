module SupportInterface
  class JobsController < SupportInterfaceController
    before_action :authorize_support_user

    private

    def authorize_support_user
      authorize nil, policy_class: ::SupportInterface::DeveloperToolPolicy
    end
  end
end
