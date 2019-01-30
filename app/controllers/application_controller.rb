class ApplicationController < ActionController::Base
  before_action :authenticate_candidate!
  layout :layout_by_resource

  def after_sign_out_path_for(resource_or_scope)
    if resource_or_scope == :admin_user || resource_or_scope.is_a?(Admin::User)
      new_admin_user_session_path
    else
      root_path
    end
  end

  # Simple way of enforcing separate layout for admin namespace Devise.
  # This can be removed if the Devise controllers are copied into the app
  # and overridden.
  def layout_by_resource
    if devise_controller? && resource_name == :admin_user
      'admin'
    else
      'application'
    end
  end
end
