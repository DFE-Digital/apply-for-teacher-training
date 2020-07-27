module ProviderInterface
  class EditProviderUserPermissionsComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :permissions_form

    def initialize(form:)
      @permissions_form = form
    end

    def training_providers_that_can(permission)
      permissions_as_ratifying_provider.map { |permission_relationship|
        permission_relationship.training_provider if permission_relationship.send("training_provider_can_#{permission}?")
      }.compact
    end

    def ratifying_providers_that_can(permission)
      permissions_as_training_provider.map { |permission_relationship|
        permission_relationship.ratifying_provider if permission_relationship.send("ratifying_provider_can_#{permission}?")
      }.compact
    end

  private

    def permissions_as_ratifying_provider
      @permissions_as_ratifying_provider ||= ProviderRelationshipPermissions.where(ratifying_provider_id: permissions_form.provider.id)
    end

    def permissions_as_training_provider
      @permissions_as_training_provider ||= ProviderRelationshipPermissions.where(training_provider_id: permissions_form.provider.id)
    end
  end
end
