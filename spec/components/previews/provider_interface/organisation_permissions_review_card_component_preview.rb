module ProviderInterface
  class OrganisationPermissionsReviewCardComponentPreview < ViewComponent::Preview
    layout 'previews/provider'

    def with_change_path
      render OrganisationPermissionsReviewCardComponent.new(
        provider_user: example_provider_user,
        provider_relationship_permission: example_provider_relationship,
        change_path: '/change',
      )
    end

    def without_change_path
      render OrganisationPermissionsReviewCardComponent.new(
        provider_user: example_provider_user,
        provider_relationship_permission: example_provider_relationship,
      )
    end

  private

    def example_provider_relationship
      @example_relationship ||= FactoryBot.build_stubbed(
        :provider_relationship_permissions,
        training_provider_can_make_decisions: [true, false].sample,
        training_provider_can_view_safeguarding_information: [true, false].sample,
        training_provider_can_view_diversity_information: [true, false].sample,
        ratifying_provider_can_make_decisions: [true, false].sample,
        ratifying_provider_can_view_safeguarding_information: [true, false].sample,
        ratifying_provider_can_view_diversity_information: [true, false].sample,
      )
    end

    def example_provider_user
      provider = [example_provider_relationship.training_provider, example_provider_relationship.ratifying_provider].sample
      FactoryBot.build_stubbed(:provider_user, providers: [provider])
    end
  end
end
