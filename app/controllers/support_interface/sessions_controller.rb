module SupportInterface
  class SessionsController < SupportInterfaceController
    skip_before_action :authenticate_support_user!

    def new; end

    def destroy
      SupportUser.end_session!(session)

      redirect_to action: :new
    end
  end
end
