require 'rails_helper'

RSpec.describe CandidateInterface::ImmigrationRightToWorkForm, type: :model do
  describe '#validations' do
    describe '.build_from_application' do
      let(:form_data) do
        {
          immigration_right_to_work: true,
        }
      end

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
        form_data = { immigration_right_to_work: false }
        application_form = FactoryBot.create(:application_form)
        form = described_class.new(form_data)

        expect(form.save(application_form)).to be(true)
        expect(application_form.immigration_right_to_work).to be(false)
      end

      it 'resets redundant attribues if right to work is false' do
        application_data = {
          immigration_right_to_work: true,
          immigration_status: 'other',
          immigration_status_details: 'I have permanent residence',
          immigration_route: 'other_route',
          immigration_route_details: 'I am eligible for permanent residence',
          immigration_entry_date: 2.years.ago.to_date,
        }
        application_form = FactoryBot.create(:application_form, application_data)
        form = described_class.new(immigration_right_to_work: false)

        expect(form.save(application_form)).to be(true)
        expect(application_form.reload.immigration_right_to_work).to be(false)
        expect(application_form.immigration_status).to be_nil
        expect(application_form.immigration_status_details).to be_nil
        expect(application_form.immigration_entry_date).to be_nil
        expect(application_form.immigration_route).not_to be_nil
        expect(application_form.immigration_route_details).not_to be_nil
      end

      it 'resets redundant attribues if right to work is true' do
        application_data = {
          immigration_right_to_work: false,
          immigration_status: 'other',
          immigration_status_details: 'I have permanent residence',
          immigration_route: 'other_route',
          immigration_route_details: 'I am eligible for permanent residence',
          immigration_entry_date: 2.years.ago.to_date,
        }
        application_form = FactoryBot.create(:application_form, application_data)
        form = described_class.new(immigration_right_to_work: true)

        expect(form.save(application_form)).to be(true)
        expect(application_form.reload.immigration_right_to_work).to be(true)
        expect(application_form.immigration_status).not_to be_nil
        expect(application_form.immigration_status_details).not_to be_nil
        expect(application_form.immigration_entry_date).not_to be_nil
        expect(application_form.immigration_route).to be_nil
        expect(application_form.immigration_route_details).to be_nil
      end
    end
  end
end
