module CandidateInterface
  module DecoupledReferences
    class RequestController < BaseController
      before_action :set_reference
      before_action :prompt_for_candidate_name_if_not_already_given, only: :new

      def new
      end

      def create
      end

    private

      def prompt_for_candidate_name_if_not_already_given
        if @reference.application_form.first_name.blank? ||
            @reference.application_form.last_name.blank?
          redirect_to candidate_interface_decoupled_references_new_candidate_name_path(@reference.id)
        end
      end
    end
  end
end

