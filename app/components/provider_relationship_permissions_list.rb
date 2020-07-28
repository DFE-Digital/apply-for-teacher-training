class ProviderRelationshipPermissionsList < ViewComponent::Base
  attr_reader :permission_model
  delegate :ratifying_provider, :training_provider, to: :permission_model

  def initialize(permission_model)
    @permission_model = permission_model
  end

  def providers_that_can(permission)
    providers_that_can = %w[training_provider ratifying_provider].map do |provider_role|
      if @permission_model.send("#{provider_role}_can_#{permission}?")
        @permission_model.send(provider_role)
      end
    end

    providers_that_can.compact
  end

  def show_view_applications_only_section?
    providers_that_can(:view_applications_only).any?
  end
end
