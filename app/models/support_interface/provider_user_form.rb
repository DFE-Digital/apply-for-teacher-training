module SupportInterface
  class ProviderUserForm
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :email_address, :dfe_sign_in_uid, :provider_ids, :available_providers

    validates_presence_of :email_address, :dfe_sign_in_uid
    validates :provider_ids, presence: true

    def save
      return false unless valid?

      ProviderUser.create!(
        email_address: email_address,
        dfe_sign_in_uid: dfe_sign_in_uid,
        provider_ids: provider_ids,
      )
    end
  end
end
