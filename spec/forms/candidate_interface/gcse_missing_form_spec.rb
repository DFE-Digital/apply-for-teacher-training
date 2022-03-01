require 'rails_helper'

RSpec.describe CandidateInterface::GcseMissingForm, type: :model do
  describe 'validations' do
    valid_text = Faker::Lorem.sentence(word_count: 200)
    long_text = Faker::Lorem.sentence(word_count: 201)

    it { is_expected.to allow_value(valid_text).for(:missing_explanation) }
    it { is_expected.not_to allow_value(long_text).for(:missing_explanation) }
  end

  describe '#build_from_qualification' do
    it 'builds the Form from the qualification model' do
      application_form = create(:application_form)

      qualification = application_form.application_qualifications.create!(
        level: 'gcse',
        subject: 'maths',
        qualification_type: 'missing',
        missing_explanation: 'Missing qualification',
      )

      form = described_class.build_from_qualification(qualification)

      expect(form.level).to eq 'gcse'
      expect(form.subject).to eq 'maths'
      expect(form.qualification_type).to eq 'missing'
      expect(form.missing_explanation).to eq('Missing qualification')
    end
  end

  describe '#save' do
    context 'when the qualification_type is missing' do
      it 'updates the qualification type and resets the other attributes' do
        qualification = create(:gcse_qualification, subject: 'maths', qualification_type: 'missing')

        form = described_class.new(
          subject: 'maths',
          level: 'gcse',
          qualification_type: 'missing',
          missing_explanation: 'Never finished',
        )

        form.save(qualification)

        qualification.reload

        expect(qualification.subject).to eq('maths')
        expect(qualification.level).to eq('gcse')
        expect(qualification.qualification_type).to eq('missing')
        expect(qualification.missing_explanation).to eq('Never finished')
        expect(qualification.grade).to be_nil
        expect(qualification.award_year).to be_nil
        expect(qualification.institution_name).to be_nil
        expect(qualification.institution_country).to be_nil
      end
    end

    context 'when it is a gcse' do
      it 'updates the missing_explanation' do
        qualification = create(:gcse_qualification, subject: 'maths')

        form = described_class.new(
          subject: 'maths',
          level: 'gcse',
          qualification_type: 'gcse',
          missing_explanation: 'Never finished',
        )

        form.save(qualification)

        qualification.reload

        expect(qualification.subject).to eq('maths')
        expect(qualification.level).to eq('gcse')
        expect(qualification.qualification_type).to eq('gcse')
        expect(qualification.missing_explanation).to eq('Never finished')
      end
    end
  end
end
