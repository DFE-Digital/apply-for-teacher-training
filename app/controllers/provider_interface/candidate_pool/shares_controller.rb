module ProviderInterface
  module CandidatePool
    class SharesController < ProviderInterfaceController
      before_action :redirect_to_applications_unless_provider_opted_in
      before_action :set_candidate
      before_action :set_back_link

      def show; end

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

      def redirect_to_applications_unless_provider_opted_in
        invites = CandidatePoolProviderOptIn.find_by(provider_id: current_provider_user.provider_ids)

        redirect_to provider_interface_applications_path if invites.blank?
      end
    end
  end
end
