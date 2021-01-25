module ProviderInterface
  class ProviderRelationshipPermissionsSetupWizard
    include ActiveModel::Model
    include Wizard

    attr_accessor :current_provider_relationship_id, :checking_answers
    attr_writer :provider_relationships, :provider_relationship_permissions, :state_store
    validate :validate_permissions_form, on: :permissions

    class PermissionsForm
      include ActiveModel::Model
      attr_accessor :id
      attr_accessor(*ProviderRelationshipPermissions::PERMISSIONS)
      validate :at_least_one_organisation_has_permissions

      def at_least_one_organisation_has_permissions
        ProviderRelationshipPermissions::PERMISSIONS.each do |permission|
          if send(permission).all?(&:blank?)
            errors.add(permission, "Select which organisations can #{permission.to_s.humanize.downcase}")
          end
        end
      end
    end

    def provider_relationships
      if @provider_relationships
        @provider_relationships.reject(&:blank?).map(&:to_i)
      else
        []
      end
    end

    def provider_relationship_permissions
      @provider_relationship_permissions || {}
    end

    def permissions_for_relationship(relationship_id = current_provider_relationship_id)
      provider_relationship_permissions.fetch(relationship_id.to_s, {})
    end

    # We hold data in the form
    # { permission_id => { permission1 => [ "training" ], permission2 => [ "training", "ratifying" ] } }
    #
    # This method massages it into attrs suitable for ProviderRelationshipPermissions models
    # and returns those models ready for persistence, either for actually saving or for previewing
    # on the check-answers page
    def permissions_for_persistence
      provider_relationship_permissions.map do |id, permissions|
        record = ProviderRelationshipPermissions.find(id)
        permissions_attributes = %w[training ratifying].reduce({}) do |hash, role|
          hash.merge({
            "#{role}_provider_can_make_decisions" => permissions.fetch('make_decisions', []).include?(role),
            "#{role}_provider_can_view_safeguarding_information" => permissions.fetch('view_safeguarding_information', []).include?(role),
            "#{role}_provider_can_view_diversity_information" => permissions.fetch('view_diversity_information', []).include?(role),
          })
        end
        record.assign_attributes(permissions_attributes)

        record
      end
    end

    # Steps are
    # 1. provider_relationships
    # 2. permissions (repeated per relationship)
    # 3. check
    def next_step
      if checking_answers.present?
        [:check]
      elsif current_step == 'organisations'
        [:permissions, next_provider_relationship_id]
      elsif current_step == 'permissions' && next_provider_relationship_id.present?
        [:permissions, next_provider_relationship_id]
      else
        [:check]
      end
    end

    def previous_step
      if checking_answers.present?
        [:check]
      elsif current_step == 'permissions'
        previous_provider_relationship_id.present? ? [:permissions, previous_provider_relationship_id] : [:organisations]
      elsif current_step == 'check'
        [:permissions, provider_relationships.last]
      else
        [:check]
      end
    end

    def current_permissions_form
      @_current_permissions_form ||= PermissionsForm.new(
        permissions_for_relationship(current_provider_relationship_id).merge(id: current_provider_relationship_id),
      )
    end

  private

    def next_provider_relationship_id
      if current_provider_relationship_id.blank?
        provider_relationships.first
      else
        provider_relationships.drop_while { |provider_relationship_id| provider_relationship_id != current_provider_relationship_id.to_i }[1]
      end
    end

    def previous_provider_relationship_id
      if current_provider_relationship_id.blank?
        provider_relationships.last
      else
        provider_relationships.reverse.drop_while { |provider_relationship_id| provider_relationship_id != current_provider_relationship_id.to_i }[1]
      end
    end

    def next_provider_relationship_needing_permissions_setup
      ProviderRelationshipPermissions.where(setup_at: nil).order(:created_at)
    end

    def any_provider_relationship_needs_permissions_setup?
      next_provider_relationship_needing_permissions_setup.present?
    end

    def validate_permissions_form
      return if current_permissions_form.valid?

      current_permissions_form.errors.map do |key, message|
        errors.add("provider_relationship_permissions[#{current_provider_relationship_id}][#{key}]", message)
      end
    end

    def enter_review_mode!
      @checking_answers = false
    end

    def params_to_exclude_from_saved_state
      super + %w[_current_permissions_form]
    end
  end
end
