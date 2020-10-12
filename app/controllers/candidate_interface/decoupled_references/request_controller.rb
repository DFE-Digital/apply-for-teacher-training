module CandidateInterface
  module DecoupledReferences
    class RequestController < BaseController
      before_action :set_reference
      before_action :prompt_for_candidate_name_if_not_already_given, only: :create

      # TODO: Replace this action when integrating with ref summary page
      def start
        @request_form = Reference::RequestForm.build_from_reference(@reference)
      end

      def new
        @request_form = Reference::RequestForm.build_from_reference(@reference)
        @request_form.request_now = 'yes'
      end

      def create
        if request_now?
          CandidateInterface::RequestReference.call(@reference)
          flash[:success] = "Reference request sent to #{@reference.name}"
        end
        redirect_to candidate_interface_decoupled_references_review_path
      end

    private

      def prompt_for_candidate_name_if_not_already_given
        if request_now? &&
            (@reference.application_form.first_name.blank? ||
             @reference.application_form.last_name.blank?)
          redirect_to candidate_interface_decoupled_references_new_candidate_name_path(@reference.id)
        end
      end

      def request_now?
        params.dig(:candidate_interface_reference_request_form, :request_now) == 'yes'
      end
    end
  end
end
