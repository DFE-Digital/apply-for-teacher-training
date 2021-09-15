module ProviderInterface
  class InviteUserWizard
    include Wizard

    attr_accessor :first_name, :last_name, :email_address, :provider, :permissions, :checking_answers

    validates :first_name, presence: true
    validates :last_name, presence: true

    validates :email_address, presence: true, valid_for_notify: true
    validate :email_not_already_used_for_provider, if: -> { email_address.present? }

    def initialize(state_store, attrs = {})
      @state_store = state_store

      super(last_saved_state.merge(attrs))

      self.checking_answers = false if current_step == :check
    end

    def current_step
      @current_step&.to_sym
    end

    def next_step
      if checking_answers || current_step == :permissions
        :check
      elsif current_step == :personal_details
        :permissions
      end
    end

    def previous_step
      if checking_answers
        :check
      elsif current_step == :check
        :permissions
      elsif current_step == :permissions
        :personal_details
      end
    end

  private

    def email_not_already_used_for_provider
      return unless provider.provider_users.exists?(email_address: email_address.downcase)

      errors.add(:email_address, :email_already_associated, provider_name: provider.name)
    end
  end
end
