module ProviderInterface
  class APITokenForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :description
    attribute :vendor_type
    attribute :vendor_name
    attribute :provider

    validates :description, presence: true
    validates :provider, presence: true
    validates :vendor_type, presence: true
    validates :vendor_name, presence: true, if: -> { vendor_type == VendorAPIToken::THIRD_PARTY }

    def self.build_from_record(token_id)
      token = VendorAPIToken.find(token_id)
      new(
        description: token.description,
        vendor_type: token.vendor.name == VendorAPIToken::IN_HOUSE ? VendorAPIToken::IN_HOUSE : VendorAPIToken::THIRD_PARTY,
        vendor_name: token.vendor.name,
        provider: token.provider,
      )
    end

    def save!
      return false unless valid?

      VendorAPIToken.create_with_random_token!(
        provider:,
        description:,
        vendor_id:,
      )
    end

  private

    def vendor_id
      if vendor_type == VendorAPIToken::IN_HOUSE
        Vendor.find_by(name: VendorAPIToken::IN_HOUSE).id
      elsif vendor_name.present?
        normalized_name = Vendor.normalize_value_for(:name, vendor_name)
        Vendor.find_or_create_by!(name: normalized_name).id
      end
    end
  end
end
