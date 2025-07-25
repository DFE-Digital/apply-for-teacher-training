require 'rails_helper'

RSpec.describe ContactDetailsAPIData do
  subject(:presenter) { ContactDetailsAPIDataClass.new(application_choice) }

  let!(:application_choice) { create(:application_choice, :awaiting_provider_decision, :with_completed_application_form) }
  let(:contact_details_data_class) do
    Class.new do
      include ContactDetailsAPIData

      attr_accessor :application_choice, :application_form

      def initialize(application_choice)
        @application_choice = ApplicationChoiceExportDecorator.new(application_choice)
        @application_form = application_choice.application_form
      end
    end
  end

  before do
    stub_const('ContactDetailsAPIDataClass', contact_details_data_class)
  end

  describe '#contact_details' do
    let(:application_choice) { create(:application_choice, :awaiting_provider_decision, application_form:) }
    let(:application_form) { create(:application_form, :minimum_info, application_form_attributes) }
    let(:application_form_attributes) do
      {
        phone_number: '07700 900 982',
        address_line1: '42',
        address_line2: 'Much Wow Street',
        address_line3: 'London',
        address_line4: 'England',
        country: 'GB',
        postcode: 'SW1P 3BT',
      }
    end

    context 'for UK addresses' do
      it 'returns contact details in correct format' do
        expected_contact_details = application_form_attributes.merge(email: application_form.candidate.email_address)

        expect(presenter.contact_details).to eq(expected_contact_details)
      end
    end

    context 'for international addresses' do
      let(:application_form_attributes) do
        {
          phone_number: '07700 900 982',
          address_type: 'international',
          address_line1: '456 Marine Drive',
          address_line2: 'Mumbai',
          address_line3: nil,
          address_line4: nil,
          international_address: '456 Marine Drive, Mumbai',
          country: 'IN',
        }
      end

      it 'returns contact details in correct format' do
        expected_contact_details = {
          phone_number: '07700 900 982',
          address_line1: '456 Marine Drive',
          address_line2: 'Mumbai',
          address_line3: nil,
          address_line4: nil,
          country: 'IN',
        }.merge(email: application_form.candidate.email_address)

        expect(presenter.contact_details).to eq(expected_contact_details)
      end
    end

    context 'if no address lines are populated' do
      let(:application_form_attributes) do
        {
          phone_number: '07700 900 982',
          address_type: 'international',
          international_address: '456 Marine Drive, Mumbai',
          address_line1: nil,
          address_line2: nil,
          address_line3: nil,
          address_line4: nil,
          country: 'IN',
        }
      end

      it 'presents the international_address field' do
        expect(presenter.contact_details).to eq({
          phone_number: '07700 900 982',
          address_line1: '456 Marine Drive, Mumbai',
          address_line2: nil,
          address_line3: nil,
          address_line4: nil,
          country: 'IN',
          email: application_form.candidate.email_address,
        })
      end
    end
  end
end
