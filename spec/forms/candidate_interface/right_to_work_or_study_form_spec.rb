require 'rails_helper'

RSpec.describe CandidateInterface::RightToWorkOrStudyForm, type: :model do
  describe '#validations' do
    let(:form) { subject }

    before do
      allow(form).to receive(:right_to_work_or_study?).and_return(true)
    end

    it { is_expected.to validate_presence_of(:right_to_work_or_study) }
    it { is_expected.to validate_presence_of(:right_to_work_or_study_details) }

    okay_text = Faker::Lorem.sentence(word_count: 200)
    long_text = Faker::Lorem.sentence(word_count: 201)

    it { is_expected.to allow_value(okay_text).for(:right_to_work_or_study_details) }
    it { is_expected.not_to allow_value(long_text).for(:right_to_work_or_study_details) }

    describe '.build_from_application' do
      let(:form_data) do
        {
          right_to_work_or_study: 'yes',
          right_to_work_or_study_details: 'I come from the land down under.',
        }
      end

      it 'creates an object based on the provided ApplicationForm' do
        application_form = ApplicationForm.new(form_data)
        right_to_work_form = described_class.build_from_application(
          application_form,
        )
        expect(right_to_work_form).to have_attributes(form_data)
      end
    end

    describe '#save' do
      let(:form_data) do
        {
          right_to_work_or_study: 'no',
          right_to_work_or_study_details: '',
        }
      end

      it 'returns false if not valid' do
        right_to_work_form = described_class.new

        expect(right_to_work_form.save(ApplicationForm.new)).to eq(false)
      end

      it 'updates the provided ApplicationForm if valid' do
        application_form = FactoryBot.create(:application_form)
        right_to_work_form = described_class.new(form_data)

        expect(right_to_work_form.save(application_form)).to eq(true)
        expect(application_form.right_to_work_or_study).to eq 'no'
        expect(application_form.right_to_work_or_study_details).to eq nil
      end
    end
  end
end
