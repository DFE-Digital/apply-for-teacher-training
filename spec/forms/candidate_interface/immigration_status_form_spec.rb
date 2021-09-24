require 'rails_helper'

RSpec.describe CandidateInterface::ImmigrationStatusForm, type: :model do
  subject(:form) { described_class.new }

  let(:form_data) do
    {
      immigration_status: 'other',
      immigration_status_details: 'I have settled status',
    }
  end

  describe 'validations' do
    context 'when the immigration status is nil' do
      it 'valiation sets immigration_status to `other`' do
        form.valid?
        expect(form.immigration_status).to eq('other')
      end
    end

    context 'when immigration_status is other' do
      before { form.immigration_status = 'other' }

      it { is_expected.to validate_presence_of(:immigration_status_details) }
    end

    context 'when immigration_status is NOT other' do
      before { form.immigration_status = 'eu_settled' }

      it { is_expected.not_to validate_presence_of(:immigration_status_details) }
    end
  end

  describe '.build_from_application' do
    it 'creates an object based on the provided ApplicationForm' do
      application_form = ApplicationForm.new(form_data)
      form = described_class.build_from_application(application_form)
      expect(form).to have_attributes(form_data)
    end
  end

  describe '#save' do
    it 'returns false if not valid' do
      form = described_class.new

      expect(form.save(ApplicationForm.new)).to be(false)
    end

    it 'updates the provided ApplicationForm if valid' do
      application_form = create(:application_form)
      form = described_class.new(form_data)

      expect(form.save(application_form)).to be(true)
      expect(application_form.immigration_status).to eq('other')
      expect(application_form.immigration_status_details).to eq('I have settled status')
    end

    it 'resets redundant attribues' do
      application_data = {
        immigration_right_to_work: true,
        immigration_status: 'other',
        immigration_status_details: 'I have permanent residence',
        immigration_route: 'other_route',
        immigration_route_details: 'I am eligible for permanent residence',
        immigration_entry_date: 2.years.ago.to_date,
      }
      application_form = create(:application_form, application_data)
      form = described_class.new(form_data)

      expect(form.save(application_form)).to be(true)
      expect(application_form.reload.immigration_right_to_work).to be(true)
      expect(application_form.immigration_status).to eq('other')
      expect(application_form.immigration_status_details).to eq('I have settled status')
      expect(application_form.immigration_route).to be_nil
      expect(application_form.immigration_route_details).to be_nil
    end
  end
end
