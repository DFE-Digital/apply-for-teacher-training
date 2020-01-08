module SupportInterface
  class ProviderUserForm
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :email_address, :provider_ids, :available_providers, :provider_user
    attr_writer :dfe_sign_in_uid

    validates_presence_of :email_address
    validates :provider_ids, presence: true
    validate :provider_user_uid_unique

    def save
      return unless valid?

      @provider_user ||= ProviderUser.new

      @provider_user.update!(
        email_address: email_address,
        dfe_sign_in_uid: dfe_sign_in_uid,
        provider_ids: provider_ids,
      )
    end

    def dfe_sign_in_uid
      @dfe_sign_in_uid&.strip == '' ? nil : @dfe_sign_in_uid # allow nil or non-whitespace
    end

    def persisted?
      provider_user && provider_user.persisted?
    end

    def self.from_provider_user(provider_user)
      new(
        provider_user: provider_user,
        available_providers: Provider.all,
        email_address: provider_user.email_address,
        provider_ids: provider_user.provider_ids,
        dfe_sign_in_uid: provider_user.dfe_sign_in_uid,
      )
    end

  private

    def provider_user_uid_unique
      if @provider_user && @provider_user.invalid?
        @provider_user.errors[:dfe_sign_in_uid].each do |error|
          errors.add(:dfe_sign_in_uid, error)
        end
      end
    end
  end
end
