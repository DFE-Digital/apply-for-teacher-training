class ApplicationController < ActionController::Base
  before_action :authenticate_candidate!

  def after_sign_out_path_for(resource_or_scope)
    if resource_or_scope == :admin_user || resource_or_scope.is_a?(Admin::User)
      new_admin_user_session_path
    else
      root_path
    end
  end
end
