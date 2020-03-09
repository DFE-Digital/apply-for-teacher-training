module SupportUsersHelper
  def support_user_account_management_path(support_user)
    if support_user.discarded?
      support_interface_confirm_restore_support_user_path(support_user)
    else
      support_interface_confirm_destroy_support_user_path(support_user)
    end
  end
end
