module CandidateInterface
  module AdviserSignUps
    class InterruptionsController < CandidateInterfaceController
      def show
        @adviser_interruption_form = CandidateInterface::AdviserInterruptionForm.new({ application_form:, proceed_to_request_adviser: params[:proceed_to_request_adviser] })
      end

      def update
        @adviser_interruption_form = CandidateInterface::AdviserInterruptionForm.new(adviser_interruption_params.merge(application_form:))

        if @adviser_interruption_form.valid?
          @adviser_interruption_form.save

          if @adviser_interruption_form.prefilled_teaching_subject?
            redirect_to candidate_interface_adviser_sign_up_path(application_form.id, preferred_teaching_subject_id: @adviser_interruption_form.prefill_preferred_teaching_subject_id)
          elsif @adviser_interruption_form.proceed_to_request_adviser?
            redirect_to new_candidate_interface_adviser_sign_up_path
          else
            redirect_to_candidate_root
          end
        else
          track_validation_error(@adviser_interruption_form)
          render :show
        end
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
