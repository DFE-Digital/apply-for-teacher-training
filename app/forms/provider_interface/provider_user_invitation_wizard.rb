module ProviderInterface
  class ProviderUserInvitationWizard
    include ActiveModel::Model
    include Wizard

    attr_accessor :current_provider_id, :first_name, :last_name, :checking_answers, :single_provider, :view_applications_only
    attr_reader :email_address
    attr_writer :providers, :provider_permissions, :state_store

    with_options(on: :details) do
      validates :email_address, :first_name, :last_name, presence: true
      validates :email_address, valid_for_notify: true
    end

    validates :providers, presence: true, on: :providers
    validates :view_applications_only, presence: { message: 'Choose whether this user has extra permissions' }, on: :permissions
    validate :at_least_one_extra_permission_is_set_if_necessary, on: :permissions

    class PermissionsForm
      include ActiveModel::Model

      attr_accessor :provider_id, :permissions

      alias_method :id, :provider_id
    end

    def providers
      if @providers
        @providers.reject(&:blank?).map(&:to_i)
      else
        []
      end
    end

    def provider_permissions
      @provider_permissions || {}
    end

    def permissions_for_provider(provider_id)
      provider_permissions[provider_id.to_s]&.dig('permissions') || []
    end

    def applicable_provider_permissions
      @provider_permissions.select do |id, _details|
        providers.include?(id.to_i)
      end
    end

    def permissions_for(provider_id)
      provider_permissions[provider_id].presence || { provider_id: provider_id, permissions: [] }
    end

    alias_method :valid_for_current_step?, :valid?

    # returns [step, *params] for the next step.
    #
    # this way the wizard is responsible for its own routing
    # but it does not need to know about HTTP, so we can test it
    # in isolation
    def next_step
      if checking_answers
        if any_provider_needs_permissions_setup?
          [:permissions, next_provider_needing_permissions_setup]
        else
          [:check]
        end
      elsif current_step == 'details'
        single_provider ? [:permissions, next_provider_id] : [:providers]
      elsif %w[providers permissions].include?(current_step) && next_provider_id.present?
        [:permissions, next_provider_id]
      else
        [:check]
      end
    end

    def previous_step
      if checking_answers
        [:check]
      elsif current_step == 'details'
        [:index]
      elsif current_step == 'providers'
        [:details]
      elsif current_step == 'permissions'
        if previous_provider_id.present?
          [:permissions, previous_provider_id]
        else
          single_provider ? [:details] : [:providers]
        end
      elsif current_step == 'check'
        [:permissions, providers.last]
      else
        [:check]
      end
    end

    def new_user?
      email_address.present? && ProviderUser.find_by(email_address: email_address).nil?
    end

    def email_address=(raw_email_address)
      @email_address = raw_email_address.downcase.strip
    end

  private

    def at_least_one_extra_permission_is_set_if_necessary
      return if ActiveModel::Type::Boolean.new.cast(view_applications_only)

      selected_permissions = permissions_for(current_provider_id).fetch('permissions', []).reject(&:blank?)
      if selected_permissions.none?
        errors[:provider_permissions] << 'Select extra permissions'
      end
    end

    def delete_permissions_if_view_applications_only(attrs)
      attrs.fetch(:provider_permissions, {}).each_key do |k|
        attrs[:provider_permissions][k].delete(:permissions) if attrs[:view_applications_only] == 'true'
      end
    end

    def next_provider_id
      if current_provider_id.blank?
        providers.first
      else
        providers.drop_while { |provider_id| provider_id != current_provider_id.to_i }[1]
      end
    end

    def previous_provider_id
      if current_provider_id.blank?
        providers.last
      else
        providers.reverse.drop_while { |provider_id| provider_id != current_provider_id.to_i }[1]
      end
    end

    def next_provider_needing_permissions_setup
      providers.find { |p| provider_permissions.keys.exclude?(p.to_s) }
    end

    def any_provider_needs_permissions_setup?
      next_provider_needing_permissions_setup.present?
    end

    def sanitize_attributes!(params)
      delete_permissions_if_view_applications_only(params)
    end

    def enter_review_mode!
      @checking_answers = false
    end

    def params_to_exclude_from_saved_state
      super + %w[current_provider_id]
    end
  end
end
