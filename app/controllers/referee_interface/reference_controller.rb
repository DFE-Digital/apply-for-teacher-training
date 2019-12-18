module RefereeInterface
  class ReferenceController < ActionController::Base
    include LogQueryParams
    before_action :add_identity_to_log
    before_action :check_referee_has_valid_token

    layout 'application'

    def feedback
      @application = reference.application_form
    end

  private

    def render_404
      render 'errors/not_found', status: :not_found
    end

    def add_identity_to_log
      return if reference.blank?

      RequestLocals.store[:identity] = { reference_id: reference.id }
      Raven.user_context(reference_id: reference.id)
    end

    def reference
      @reference ||= ApplicationReference.find_by_unhashed_token(params[:token])
    end

    def check_referee_has_valid_token
      render_404 unless reference
    end
  end
end
