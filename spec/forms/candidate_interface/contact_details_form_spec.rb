require 'rails_helper'

RSpec.describe CandidateInterface::ContactDetailsForm, type: :model do
  describe '.build_from_application' do
    it 'creates an object based on the provided ApplicationForm' do
      data = {
        phone_number: Faker::PhoneNumber.cell_phone,
        address_line1: Faker::Address.street_name,
        address_line2: Faker::Address.street_address,
        address_line3: Faker::Address.city,
        address_line4: 'United Kingdom',
        postcode: Faker::Address.postcode,
      }
      application_form = build_stubbed(:application_form, data)
      contact_details = described_class.build_from_application(application_form)

      expect(contact_details).to have_attributes(data)
    end
  end

  describe '#save_base' do
    it 'returns false if not valid' do
      contact_details = described_class.new

      expect(contact_details.save_base(ApplicationForm.new)).to eq(false)
    end

    it 'updates the provided ApplicationForm if valid' do
      form_data = { phone_number: Faker::PhoneNumber.cell_phone }
      application_form = build(:application_form)
      contact_details = described_class.new(form_data)

      expect(contact_details.save_base(application_form)).to eq(true)
      expect(application_form).to have_attributes(form_data)
    end
  end

  describe '#save_address' do
    it 'returns false if not valid' do
      contact_details = described_class.new

      expect(contact_details.save_address(ApplicationForm.new)).to eq(false)
    end

    it 'updates the provided ApplicationForm with the address fields if valid' do
      form_data = {
        address_type: 'uk',
        address_line1: Faker::Address.street_name,
        address_line2: Faker::Address.street_address,
        address_line3: Faker::Address.city,
        address_line4: 'United Kingdom',
        postcode: 'bn1 1aa',
      }
      application_form = build(:application_form, international_address: 'some old address')
      contact_details = described_class.new(form_data)

      form_data[:postcode] = 'BN1 1AA'

      expect(contact_details.save_address(application_form)).to eq(true)
      expect(application_form).to have_attributes(form_data)
    end

    it 'updates the provided ApplicationForm with the international address field if valid' do
      form_data = {
        address_line1: '123 Chandni Chowk',
        address_line3: 'Old Delhi',
        address_line4: '110006',
      }
      application_form = build(:application_form)
      contact_details = described_class.new(form_data)

      expect(contact_details.save_address(application_form)).to eq(true)
      expect(application_form).to have_attributes(form_data)
      expect(application_form.address_line2).to be_nil
      expect(application_form.address_line4).to eq '110006'
      expect(application_form.postcode).to be_nil
    end
  end

  describe '#save_address_type' do
    it 'updates the provided ApplicationForm with the address type fields for a valid UK address' do
      form_data = {
        address_type: 'uk',
      }
      application_form = build(:application_form)
      contact_details = described_class.new(form_data)

      expect(contact_details.save_address_type(application_form)).to eq(true)
      expect(application_form).to have_attributes(form_data)
    end

    it 'updates the provided ApplicationForm with the address type fields for a valid international address' do
      form_data = {
        address_type: 'international',
        country: 'India',
      }
      application_form = build(:application_form)
      contact_details = described_class.new(form_data)

      expect(contact_details.save_address_type(application_form)).to eq(true)
      expect(application_form).to have_attributes(form_data)
    end

    it 'returns validation errors for an invalid international address' do
      form_data = {
        address_type: 'international',
      }
      application_form = build(:application_form)
      contact_details = described_class.new(form_data)

      expect(contact_details.save_address_type(application_form)).to eq(false)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:address_type).on(:address_type) }

    context 'for a UK address' do
      subject(:form) { described_class.new(address_type: 'uk') }

      it { is_expected.to validate_presence_of(:address_line1).on(:address) }
      it { is_expected.to validate_presence_of(:address_line3).on(:address) }
      it { is_expected.to validate_presence_of(:postcode).on(:address) }
      it { is_expected.not_to allow_value('MUCH WOW').for(:postcode).on(:address) }
    end

    context 'for an international address' do
      subject(:form) { described_class.new(address_type: 'international') }

      it { is_expected.to validate_presence_of(:address_line1).on(:address) }
      it { is_expected.not_to validate_presence_of(:address_line3).on(:address) }
      it { is_expected.not_to validate_presence_of(:postcode).on(:address) }
      it { is_expected.to allow_value('MUCH WOW').for(:postcode).on(:address) }
    end

    it { is_expected.to validate_length_of(:address_line1).is_at_most(50).on(:address) }
    it { is_expected.to validate_length_of(:address_line2).is_at_most(50).on(:address) }
    it { is_expected.to validate_length_of(:address_line3).is_at_most(50).on(:address) }
    it { is_expected.to validate_length_of(:address_line4).is_at_most(50).on(:address) }

    it { is_expected.to allow_value('SW1P 3BT').for(:postcode).on(:address) }

    it { is_expected.to allow_value('07700 900 982').for(:phone_number).on(:base) }
    it { is_expected.not_to allow_value('07700 WUT WUT').for(:phone_number).on(:base) }
    it { is_expected.to validate_length_of(:phone_number).is_at_most(50).on(:base) }
  end
end
