require 'rails_helper'

RSpec.describe SupportInterface::ApplicationForms::EditAddressDetailsForm, type: :model do
  describe '.build_from_application_form' do
    it 'creates an object based on the provided ApplicationForm' do
      data = {
        address_line1: Faker::Address.street_name,
        address_line2: Faker::Address.street_address,
        address_line3: Faker::Address.city,
        address_line4: 'United Kingdom',
        postcode: Faker::Address.postcode,
        audit_comment: 'Updated as part of Zendesk ticket 12345',
      }
      details_form = described_class.new(data)

      expect(details_form).to have_attributes(data)
    end
  end

  describe '#save_address' do
    it 'returns false if not valid' do
      details_form = described_class.new

      expect(details_form.save_address(ApplicationForm.new)).to eq(false)
    end

    it 'updates the provided ApplicationForm with the address fields if valid' do
      data = {
        address_line1: Faker::Address.street_name,
        address_line2: Faker::Address.street_address,
        address_line3: Faker::Address.city,
        address_line4: 'United Kingdom',
        postcode: 'bn1 1aa',
        address_type: 'uk',
        audit_comment: 'Updated as part of Zendesk ticket 12345',
      }
      application_form = build(:application_form)
      details_form = described_class.new(data)
      data[:postcode] = 'BN1 1AA'
      data.except!(:audit_comment)

      expect(details_form.save_address(application_form)).to eq(true)
      expect(application_form).to have_attributes(data)
      expect(application_form.international_address).to be_nil
    end

    it 'updates the provided ApplicationForm with the international address field if valid' do
      data = {
        address_line1: '123 Chandni Chowk',
        address_line3: 'Old Delhi',
        address_line4: '110006',
        audit_comment: 'Updated as part of Zendesk ticket 12345',
      }
      application_form = build(:application_form)
      details_form = described_class.new(data.merge(address_type: 'international'))
      data.except!(:audit_comment)

      expect(details_form.save_address(application_form)).to eq(true)
      expect(application_form).to have_attributes(data)
      expect(application_form.address_line2).to be_nil
      expect(application_form.international_address).to be_nil
    end
  end

  describe '#save_address_type' do
    it 'updates the provided ApplicationForm with the address type fields for a valid UK address' do
      data = {
        address_type: 'uk',
      }
      application_form = build(:application_form)
      details_form = described_class.new(data)

      expect(details_form.save_address_type(application_form)).to eq(true)
      expect(application_form).to have_attributes(data)
    end

    it 'updates the provided ApplicationForm with the address type fields for a valid international address' do
      data = {
        address_type: 'international',
        country: 'India',
      }
      application_form = build(:application_form)
      details_form = described_class.new(data)

      expect(details_form.save_address_type(application_form)).to eq(true)
      expect(application_form).to have_attributes(data)
    end

    it 'returns validation errors for an invalid international address' do
      data = {
        address_type: 'international',
      }
      application_form = build(:application_form)
      details_form = described_class.new(data)

      expect(details_form.save_address_type(application_form)).to eq(false)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:address_type).on(:address_type) }

    context 'for a UK address' do
      subject(:form) { described_class.new(address_type: 'uk') }

      it { is_expected.to validate_presence_of(:address_line1).on(:address) }
      it { is_expected.to validate_presence_of(:address_line3).on(:address) }
      it { is_expected.to validate_presence_of(:postcode).on(:address) }
      it { is_expected.to validate_presence_of(:audit_comment).on(:address) }
      it { is_expected.not_to allow_value('MUCH WOW').for(:postcode).on(:address) }
    end

    context 'for an international address' do
      subject(:form) { described_class.new(address_type: 'international') }

      it { is_expected.to validate_presence_of(:address_line1).on(:address) }
      it { is_expected.not_to validate_presence_of(:address_line3).on(:address) }
      it { is_expected.not_to validate_presence_of(:postcode).on(:address) }
      it { is_expected.to validate_absence_of(:postcode).on(:address) }
    end

    it { is_expected.to validate_length_of(:address_line1).is_at_most(50).on(:address) }
    it { is_expected.to validate_length_of(:address_line2).is_at_most(50).on(:address) }
    it { is_expected.to validate_length_of(:address_line3).is_at_most(50).on(:address) }
    it { is_expected.to validate_length_of(:address_line4).is_at_most(50).on(:address) }

    it { is_expected.to allow_value('SW1P 3BT').for(:postcode).on(:address) }
  end
end
