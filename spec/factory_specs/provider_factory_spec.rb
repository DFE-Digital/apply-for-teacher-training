require 'rails_helper'

RSpec.describe 'Provider factory' do
  subject(:record) { |attrs: {}| create(factory, *traits, **attributes, **attrs) }

  let(:traits) { [] }
  let(:attributes) { {} }

  factory :provider do
    it 'creates one provider' do
      expect { record }.to change { Provider.count }.by(1)
    end

    field :code, matches: /\A[A-Z0-9]{3}\z/
    field :name, type: String
    field :region_code, value: 'london'

    it 'creates one provider agreement' do
      expect { record }.to change { ProviderAgreement.count }.by(1)
    end

    it 'associates the provider agreement with the provider' do
      expect(record.provider_agreements).to be_present
    end

    it 'creates one provider permissions' do
      expect { record }.to change { ProviderPermissions.count }.by(1)
    end

    it 'associates the provider permissions with the provider' do
      expect(record.provider_permissions).to be_present
    end

    trait :unsigned do
      it 'creates no provider agreements' do
        expect { record }.not_to(change { ProviderAgreement.count })
      end
    end

    trait :no_users do
      it 'creates no provider permissions' do
        expect { record }.not_to(change { ProviderPermissions.count })
      end
    end

    trait :with_vendor do
      it 'creates one vendor' do
        expect { record }.to change { Vendor.count }.by(1)
      end

      it 'associates the vendor with the provider' do
        expect(record.vendor).to be_present
      end

      it 'sets the vendor name to "in_house"' do
        expect(record.vendor.name).to eq('in_house')
      end

      context 'with an existing vendor with the same name' do
        let!(:existing_vendor) { create(:vendor, name: 'in_house') }

        it 'creates no vendors' do
          expect { record }.not_to(change { Vendor.count })
        end

        it 'finds the existing vendor' do
          expect(record.vendor).to eq(existing_vendor)
        end
      end
    end

    trait :with_api_token do
      it 'creates one vendor API token' do
        expect { record }.to change { VendorAPIToken.count }.by(1)
      end

      it 'associates the vendor API token with the provider' do
        expect(record.vendor_api_tokens).to be_present
      end

      it 'associates the provider to the token' do
        record
        expect(VendorAPIToken.last.provider).to eq(record)
      end
    end
  end
end
