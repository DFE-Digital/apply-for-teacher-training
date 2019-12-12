module RefereeInterface
  class ReferenceController < ActionController::Base
    layout 'application'

    def comments
      reference = Reference.find_by(token: params[:token])

      if reference.present?
        @application = reference.application_form
      else
        render_404
      end
    end

  private

    def render_404
      render 'errors/not_found', status: :not_found
    end
  end
end
