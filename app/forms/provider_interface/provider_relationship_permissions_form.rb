module ProviderInterface
  class ProviderRelationshipPermissionsForm
    include ActiveModel::Model

    attr_accessor :permissions_model, :make_decisions, :view_safeguarding_information
    delegate :errors, :training_provider, :ratifying_provider, to: :permissions_model

    def initialize(attrs)
      super(attrs)

      @make_decisions ||= providers_currently_having_permission_to('make_decisions')
      @view_safeguarding_information ||= providers_currently_having_permission_to('view_safeguarding_information')
    end

    def save!
      @permissions_model.assign_attributes(permissions_attributes_for_persistence)

      if @permissions_model.valid?
        @permissions_model.save!
      end
    end

  private

    def permissions_attributes_for_persistence
      %w[training ratifying].reduce({}) do |hash, role|
        hash.merge({
          "#{role}_provider_can_make_decisions" => @make_decisions.include?(role),
          "#{role}_provider_can_view_safeguarding_information" => @view_safeguarding_information.include?(role),
        })
      end
    end

    def providers_currently_having_permission_to(permission)
      %w[training ratifying].reduce([]) do |list, role|
        list.push(role) if @permissions_model.send("#{role}_provider_can_#{permission}?")

        list
      end
    end
  end
end
