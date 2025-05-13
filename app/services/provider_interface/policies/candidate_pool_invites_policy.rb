module ProviderInterface
  module Policies
    class CandidatePoolInvitesPolicy
      attr_reader :provider_user
      def initialize(provider_user)
        @provider_user = provider_user
      end

      def can_invite_candidates?
        decision_making_providers.any?
      end

      def can_edit_invite?(invite)
        invite.provider_id.in?(decision_making_providers.pluck(:id))
      end
      alias can_view_invite? can_edit_invite?

    private

      def decision_making_providers
        @decision_making_providers ||= provider_user.providers_where_user_can_make_decisions
      end
    end
  end
end
