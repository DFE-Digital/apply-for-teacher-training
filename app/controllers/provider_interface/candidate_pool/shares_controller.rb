module ProviderInterface
  module CandidatePool
    class SharesController < ProviderInterfaceController
      before_action :set_candidate
      before_action :set_back_link

      def show
        @candidate_profile_link = provider_interface_candidate_pool_candidate_url(@candidate)
      end

    private

      def set_candidate
        @application_form = Pool::Candidates.application_forms_for_provider
          .find_by(candidate_id: params.expect(:candidate_id))

        redirect_to provider_interface_applications_path if @application_form.nil?

        @candidate = @application_form.candidate
      end

      def set_back_link
        @back_link ||= if params[:return_to].present?
                         provider_interface_candidate_pool_candidate_url(
                           @candidate,
                           return_to: params[:return_to],
                         )
                       else
                         provider_interface_candidate_pool_candidate_url(@candidate)
                       end
      end
    end
  end
end
