require 'rails_helper'

RSpec.describe CandidateInterface::ContactDetailsForm, type: :model do
  describe '.build_from_application' do
    it 'creates an object based on the provided ApplicationForm' do
      data = {
        phone_number: Faker::PhoneNumber.cell_phone,
        address_line1: Faker::Address.street_name,
        address_line2: Faker::Address.street_address,
        address_line3: Faker::Address.city,
        address_line4: Faker::Address.country,
        postcode: Faker::Address.postcode,
      }
      application_form = build_stubbed(:application_form, data)
      contact_details = CandidateInterface::ContactDetailsForm.build_from_application(application_form)

      expect(contact_details).to have_attributes(data)
    end
  end

  describe '#save_base' do
    it 'returns false if not valid' do
      contact_details = CandidateInterface::ContactDetailsForm.new

      expect(contact_details.save_base(ApplicationForm.new)).to eq(false)
    end

    it 'updates the provided ApplicationForm if valid' do
      form_data = { phone_number: Faker::PhoneNumber.cell_phone }
      application_form = build(:application_form)
      contact_details = CandidateInterface::ContactDetailsForm.new(form_data)

      expect(contact_details.save_base(application_form)).to eq(true)
      expect(application_form).to have_attributes(form_data)
    end
  end

  describe '#save_address' do
    it 'returns false if not valid' do
      contact_details = CandidateInterface::ContactDetailsForm.new

      expect(contact_details.save_address(ApplicationForm.new)).to eq(false)
    end

    it 'updates the provided ApplicationForm with the address fields if valid' do
      form_data = {
        address_line1: Faker::Address.street_name,
        address_line2: Faker::Address.street_address,
        address_line3: Faker::Address.city,
        address_line4: Faker::Address.country,
        postcode: 'bn1 1aa',
      }
      application_form = build(:application_form)
      contact_details = CandidateInterface::ContactDetailsForm.new(form_data)

      form_data[:postcode] = 'BN1 1AA'

      expect(contact_details.save_address(application_form)).to eq(true)
      expect(application_form).to have_attributes(form_data)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:address_line1).on(:address) }
    it { is_expected.to validate_presence_of(:address_line3).on(:address) }
    it { is_expected.to validate_presence_of(:postcode).on(:address) }

    it { is_expected.to validate_length_of(:address_line1).is_at_most(50).on(:address) }
    it { is_expected.to validate_length_of(:address_line2).is_at_most(50).on(:address) }
    it { is_expected.to validate_length_of(:address_line3).is_at_most(50).on(:address) }
    it { is_expected.to validate_length_of(:address_line4).is_at_most(50).on(:address) }

    it { is_expected.to allow_value('SW1P 3BT').for(:postcode).on(:address) }
    it { is_expected.not_to allow_value('MUCH WOW').for(:postcode).on(:address) }

    it { is_expected.to allow_value('07700 900 982').for(:phone_number).on(:base) }
    it { is_expected.not_to allow_value('07700 WUT WUT').for(:phone_number).on(:base) }
    it { is_expected.to validate_length_of(:phone_number).is_at_most(50).on(:base) }
  end
end
