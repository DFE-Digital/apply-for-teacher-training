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
      @provider_user = ProviderUser.new(
        email_address: email_address,
        dfe_sign_in_uid: dfe_sign_in_uid,
        provider_ids: provider_ids,
      )

      valid? && @provider_user.save!
    end

    def dfe_sign_in_uid
      @dfe_sign_in_uid&.strip == '' ? nil : @dfe_sign_in_uid # allow nil or non-whitespace
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
