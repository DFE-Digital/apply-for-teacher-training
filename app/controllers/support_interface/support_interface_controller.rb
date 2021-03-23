module SupportInterface
  class SupportInterfaceController < ApplicationController
    layout 'support_layout'
    before_action :authenticate_support_user!
    before_action :add_identity_to_log

    helper_method :current_support_user, :dfe_sign_in_user

    def current_support_user
      @current_support_user ||= SupportUser.load_from_session(session)
    end

    def dfe_sign_in_user
      DfESignInUser.load_from_session(session)
    end

    alias_method :audit_user, :current_support_user
    alias_method :current_user, :current_support_user

  private

    def render_404
      render 'errors/not_found', status: :not_found
    end

    def authenticate_support_user!
      return if current_support_user

      session['post_dfe_sign_in_path'] = request.fullpath
      redirect_to support_interface_sign_in_path
    end

    def add_identity_to_log
      return unless current_support_user

      RequestLocals.store[:identity] = { support_user_id: current_support_user.id }
      Raven.user_context(id: "support_#{current_support_user.id}")
    end
  end
end
