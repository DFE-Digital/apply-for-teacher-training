module SupportInterface
  class SupportInterfaceController < ApplicationController
    layout 'support_layout'
    before_action :authenticate_support_user!
    before_action :set_user_context

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

    def set_user_context
      return unless current_support_user

      Raven.user_context(id: "support_#{current_support_user.id}")
    end

    def append_info_to_payload(payload)
      super

      payload.merge!({ support_user_id: current_support_user.id }) if current_support_user
      payload.merge!(log_query_params)
    end
  end
end
