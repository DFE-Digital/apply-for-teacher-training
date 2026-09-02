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
    validates :vendor_name, presence: true, if: -> { vendor_type == 'third_party' }

    def self.build_from_record(token_id)
      token = VendorAPIToken.find(token_id)
      new(
        description: token.description,
        vendor_type: token.in_house_developers ? 'in_house' : 'third_party',
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
        in_house_developers: vendor_type == 'in_house',
      )
    end

  private

    def vendor_id
      if vendor_name.present?
        normalized_name = Vendor.normalize_value_for(:name, vendor_name)
        Vendor.find_by(name: normalized_name)&.id ||
          create_vendor_return_id(normalized_name)
      end
    end

    def create_vendor_return_id(name)
      ActiveRecord::Base.transaction do
        Vendor.create!(name:, status: :unconfirmed).id
      end
    end
  end
end
