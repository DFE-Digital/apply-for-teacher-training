module CandidateInterface
  module AdviserSignUps
    class InterruptionsController < CandidateInterfaceController
      def show
        @adviser_interruption_form = CandidateInterface::AdviserInterruptionForm.new({ application_form:, proceed_to_request_adviser: params[:proceed_to_request_adviser] })
        @application_form = application_form
      end

      def update
        @adviser_interruption_form = CandidateInterface::AdviserInterruptionForm.new(adviser_interruption_params.merge(application_form:))
        @application_form = application_form

        if @adviser_interruption_form.valid?
          if @adviser_interruption_form.proceed_to_request_adviser?
            application_form.update(adviser_interruption_responded_yes: true)
            redirect_to new_candidate_interface_adviser_sign_up_path
          else
            application_form.update(adviser_interruption_responded_yes: false)
            redirect_to_candidate_root
          end
        else
          track_validation_error(@adviser_interruption_form)
          render :show
        end
        binding.pry
      end

    private

      def application_form
        current_candidate.current_application
      end

      def adviser_interruption_params
        params
          .fetch(:candidate_interface_adviser_interruption_form, {})
          .permit(:proceed_to_request_adviser)
      end
    end
  end
end
