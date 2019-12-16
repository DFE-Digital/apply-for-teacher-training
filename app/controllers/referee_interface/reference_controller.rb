module RefereeInterface
  class ReferenceController < ActionController::Base
    layout 'application'

    def feedback
      if reference.present?
        @reference_form = RefereeInterface::ReferenceForm.build_from_reference(reference)
        @application = reference.application_form
      else
        render_404
      end
    end

    def submit_feedback
      reference.feedback = params[:reference][:comments]
      @application = reference.application_form

      @reference_form = RefereeInterface::ReferenceForm.build_from_reference(reference)

      if @reference_form.save(reference)
        redirect_to referee_interface_confirmation_path
      else
        render :feedback
      end
    end

    def finish; end

    def confirmation
      if reference.present?
        render :confirmation
      else
        render_404
      end
    end

    def decline
      if reference.present?
        @application = reference.application_form
        #TODO: add logic to record this and notify candidate
        render :decline
      else
        render_404
      end
    end

  private

    def render_404
      render 'errors/not_found', status: :not_found
    end

    def reference
      @reference ||= Reference.find_by(token: params[:token])
    end
  end
end
