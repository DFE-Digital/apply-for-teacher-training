module SupportInterface
  class SupportUsersController < SupportInterfaceController
    def index
      @support_users = SupportUser.all
    end
  end
end
