module CandidateInterface
  module DecoupledReferences
    class ReviewController < BaseController
      before_action :set_reference

      def show
        @application_form = current_application
        @references_given = current_application.application_references.feedback_provided
        @references_waiting_to_be_sent = current_application.application_references.not_requested_yet
        @references_sent = current_application.application_references.pending_feedback_or_failed
      end

      def unsubmitted
        @submit_reference_form = Reference::RefereeSubmitForm.new
      end

      def submit
        @submit_reference_form = Reference::RefereeSubmitForm.new(submit: submit_param)
        return render :unsubmitted unless @submit_reference_form.valid?

        if @submit_reference_form.submit == 'yes'
          if Reference::RefereeTypeForm.build_from_reference(@reference).valid? &&
            Reference::RefereeNameForm.build_from_reference(@reference).valid? &&
            Reference::RefereeRelationshipForm.build_from_reference(@reference).valid? &&
            Reference::RefereeEmailAddressForm.build_from_reference(@reference).valid?

            redirect_to candidate_interface_decoupled_references_create_candidate_name_path(@reference.id)
          else
            # TODO: Once the forms are moved into objects this won't be necessary
            # It can just call valid? and render the errors.
            flash[:warning] = 'You must complete all of your referees details before your reference request can be submitted'

            render :unsubmitted
          end
        else
          redirect_to candidate_interface_decoupled_references_review_path
        end
      end

      def confirm_destroy
        @reference = ApplicationReference.find(params[:id])
      end

      def destroy
        @reference = ApplicationReference.find(params[:id])
        @reference.destroy!
        redirect_to candidate_interface_decoupled_references_review_path
      end

    private

      def submit_param
        params.dig(:candidate_interface_reference_referee_submit_form, :submit)
      end
    end
  end
end
