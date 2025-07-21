require 'rails_helper'

RSpec.describe SupportInterface::ApplicationForms::ImmigrationRightToWorkForm, type: :model do
  subject(:form) do
    described_class.new(
      right_to_work_or_study:,
      right_to_work_or_study_details:,
      audit_comment: 'test',
    )
  end

  let(:right_to_work_or_study) { 'yes' }
  let(:right_to_work_or_study_details) { 'details' }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:right_to_work_or_study) }
    it { is_expected.to validate_presence_of(:audit_comment) }
  end

  describe '.build_from_application' do
    it 'creates an object based on the provided ApplicationForm' do
      application_form = ApplicationForm.new(
        right_to_work_or_study:,
        right_to_work_or_study_details:,
      )
      form = described_class.build_from_application(application_form)

      expect(form).to have_attributes(
        right_to_work_or_study:,
        right_to_work_or_study_details:,
      )
    end
  end

  describe '#save' do
    context 'invalid' do
      subject(:form) { described_class.new }

      it 'returns false if not valid' do
        expect(form.save(ApplicationForm.new)).to be(false)
      end
    end

    context 'when right_to_work_or_study is yes' do
      it 'updates the provided ApplicationForm if valid' do
        application_form = create(:application_form)

        expect(form.save(application_form)).to be(true)
        expect(application_form.right_to_work_or_study).to eq('yes')
        expect(application_form.right_to_work_or_study_details).to eq('details')
      end
    end

    context 'when right_to_work_or_study is not yes' do
      let(:right_to_work_or_study) { 'no' }

      it 'updates application form and sets right_to_work_or_study_details and immigration_status to nil' do
        application_form = create(:application_form, immigration_status: 'eu_settled')

        expect(form.save(application_form)).to be(true)
        expect(application_form.right_to_work_or_study).to eq('no')
        expect(application_form.right_to_work_or_study_details).to be_nil
        expect(application_form.immigration_status).to be_nil
      end
    end
  end
end
