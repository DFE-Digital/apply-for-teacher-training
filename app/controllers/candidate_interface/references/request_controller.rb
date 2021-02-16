module CandidateInterface
  module References
    class RequestController < BaseController
      before_action :prompt_for_candidate_name_if_not_already_given, only: :create
      before_action :verify_reference_can_be_requested

      def new
        @request_form = Reference::RequestForm.build_from_reference(@reference)
        @request_form.request_now = 'yes'
      end

      def create
        if request_now?
          RequestReference.new.call(@reference)
          flash[:success] = "Reference request sent to #{@reference.name}"
        end

        redirect_to candidate_interface_references_review_path
      end

    private

      def verify_reference_can_be_requested
        policy = ReferenceActionsPolicy.new(@reference)

        render_404 and return unless policy.can_request?
      end

      def prompt_for_candidate_name_if_not_already_given
        if request_now? &&
            (@reference.application_form.first_name.blank? ||
             @reference.application_form.last_name.blank?)
          redirect_to candidate_interface_references_new_candidate_name_path(@reference.id)
        end
      end

      def request_now?
        params.dig(:candidate_interface_reference_request_form, :request_now) == 'yes'
      end
    end
  end
end
