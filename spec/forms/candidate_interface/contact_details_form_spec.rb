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

      expect(contact_details.save_base(ApplicationForm.new)).to be(false)
    end

    it 'updates the provided ApplicationForm if valid' do
      form_data = { phone_number: Faker::PhoneNumber.cell_phone }
      application_form = build(:application_form)
      contact_details = described_class.new(form_data)

      expect(contact_details.save_base(application_form)).to be(true)
      expect(application_form).to have_attributes(form_data)
    end
  end

  describe '#save_address' do
    it 'returns false if not valid' do
      contact_details = described_class.new

      expect(contact_details.save_address(ApplicationForm.new)).to be(false)
    end

    it 'updates the provided ApplicationForm with the address fields if valid' do
      form_data = {
        address_type: 'uk',
        address_line1: Faker::Address.street_name,
        address_line2: Faker::Address.street_address,
        address_line3: Faker::Address.city,
        address_line4: 'United Kingdom',
        postcode: '  bn1 1aa  ',
      }
      application_form = build(:application_form, international_address: 'some old address')
      contact_details = described_class.new(form_data)

      form_data[:postcode] = 'BN1 1AA'

      expect(contact_details.save_address(application_form)).to be(true)
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

      expect(contact_details.save_address(application_form)).to be(true)
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

      expect(contact_details.save_address_type(application_form)).to be(true)
      expect(application_form).to have_attributes(form_data)
    end

    it 'updates the provided ApplicationForm with the address type fields for a valid international address' do
      form_data = {
        address_type: 'international',
        country: 'India',
      }
      application_form = build(:application_form)
      contact_details = described_class.new(form_data)

      expect(contact_details.save_address_type(application_form)).to be(true)
      expect(application_form).to have_attributes(form_data)
    end

    it 'returns validation errors for an invalid international address' do
      form_data = {
        address_type: 'international',
      }
      application_form = build(:application_form)
      contact_details = described_class.new(form_data)

      expect(contact_details.save_address_type(application_form)).to be(false)
    end

    it 'resets the `contact_details_completed` flag if data is incomplete' do
      form_data = {
        address_type: 'uk',
        phone_number: '0123456789',
        address_line1: '123 Long Road',
      }
      application_form = create(
        :application_form,
        phone_number: '0123456789',
        address_type: 'international',
        address_line1: '123 Long Road',
        contact_details_completed: true,
      )
      contact_details = described_class.new(form_data)

      expect(contact_details.save_address_type(application_form)).to be(true)
      expect(application_form.reload.contact_details_completed).to be_nil
    end

    it 'preserves the `contact_details_completed` flag if data is complete' do
      form_data = {
        address_type: 'uk',
        phone_number: '0123456789',
        address_line1: '123 Long Road',
        address_line3: 'Bigtown',
        postcode: 'BN1 1BN',
      }
      application_form = create(
        :application_form,
        phone_number: '0123456789',
        address_type: 'international',
        address_line1: '123 Long Road',
        address_line3: 'Bigtown',
        postcode: 'BN1 1BN',
        contact_details_completed: true,
      )
      contact_details = described_class.new(form_data)

      expect(contact_details.save_address_type(application_form)).to be(true)
      expect(application_form.reload.contact_details_completed).to be(true)
    end

    it 'resets the postcode to nil if changing a UK address to international' do
      form_data = {
        address_type: 'international',
        country: 'FR',
      }
      application_form = create(
        :application_form,
        phone_number: '0123456789',
        address_type: 'international',
        address_line1: '123 Long Road',
        address_line3: 'Bigtown',
        postcode: 'BN1 1BN',
      )
      contact_details = described_class.new(form_data)

      expect(contact_details.save_address_type(application_form)).to be(true)
      expect(application_form.reload.address_type).to eq('international')
      expect(application_form.country).to eq('FR')
      expect(application_form.address_line1).to eq('123 Long Road')
      expect(application_form.postcode).to be_nil
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

      it { is_expected.to validate_length_of(:address_line1).is_at_most(50).on(:address) }
      it { is_expected.to validate_length_of(:address_line2).is_at_most(50).on(:address) }
      it { is_expected.to validate_length_of(:address_line3).is_at_most(50).on(:address) }
      it { is_expected.to validate_length_of(:address_line4).is_at_most(50).on(:address) }
    end

    context 'for an international address' do
      subject(:form) { described_class.new(address_type: 'international') }

      it { is_expected.not_to validate_presence_of(:address_line3).on(:address) }
      it { is_expected.not_to validate_presence_of(:postcode).on(:address) }
      it { is_expected.to allow_value('MUCH WOW').for(:postcode).on(:address) }
    end

    it { is_expected.to allow_value('SW1P 3BT').for(:postcode).on(:address) }

    it { is_expected.to allow_value('07700 900 982').for(:phone_number).on(:base) }
    it { is_expected.not_to allow_value('07700 WUT WUT').for(:phone_number).on(:base) }
  end

  describe 'custom validations' do
    let(:error_attr) { 'activemodel.errors.models.candidate_interface/contact_details_form.attributes' }
    let(:application_form) { build(:application_form) }

    context 'international address presence' do
      it 'is invalid' do
        contact_details = described_class.new(address_type: 'international', address_line1: '')

        expect(contact_details.save_address(application_form)).to be(false)
        expect(contact_details.errors[:address_line1]).to include(I18n.t("#{error_attr}.address_line1.international_blank"))
      end
    end

    context 'international address maximum length' do
      it 'is invalid' do
        contact_details = described_class.new(address_type: 'international', address_line1: SecureRandom.alphanumeric(51),
                                              address_line2: '', address_line3: '', address_line4: '')

        expect(contact_details.save_address(application_form)).to be(false)
        expect(contact_details.errors[:address_line1]).to include(I18n.t("#{error_attr}.address_line1.international_too_long", count: described_class::MAX_LENGTH))
      end
    end
  end
end
