require 'rails_helper'

RSpec.describe Vendor do
  describe 'validations' do
    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
    it { is_expected.to validate_presence_of(:name) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:providers) }
    it { is_expected.to have_many(:vendor_api_tokens) }
  end

  describe 'normalizes name' do
    it 'changes string name to snake case string' do
      vendor = create(:vendor, name: ' Thomas &   Moore   vendor 1^*')
      expect(vendor.name).to eq 'thomas_and_moore_vendor_1'
    end

    it 'changes symbol name to snake case string' do
      vendor = create(:vendor, name: :important_vendor)
      expect(vendor.name).to eq 'important_vendor'
    end
  end

  describe 'enum' do
    it { is_expected.to define_enum_for(:status).with_values(confirmed: 'confirmed', unconfirmed: 'unconfirmed').backed_by_column_of_type(:string) }
  end
end
