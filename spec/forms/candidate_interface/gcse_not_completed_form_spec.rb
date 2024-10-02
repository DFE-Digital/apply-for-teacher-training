require 'rails_helper'

RSpec.describe CandidateInterface::GcseNotCompletedForm, type: :model do
  describe 'validations' do
    valid_text = Faker::Lorem.characters(number: 256)
    long_text = Faker::Lorem.characters(number: 257)

    it { is_expected.to allow_value(valid_text).for(:not_completed_explanation) }
    it { is_expected.not_to allow_value(long_text).for(:not_completed_explanation) }
  end

  describe '#build_from_qualification' do
    it 'builds the Form from the qualification model' do
      application_form = create(:application_form)

      qualification = application_form.application_qualifications.create!(
        level: 'gcse',
        subject: 'maths',
        qualification_type: 'missing',
        not_completed_explanation: 'Still in progress',
      )

      form = described_class.build_from_qualification(qualification)

      expect(form.level).to eq 'gcse'
      expect(form.subject).to eq 'maths'
      expect(form.qualification_type).to eq 'missing'
      expect(form.not_completed_explanation).to eq('Still in progress')
    end
  end

  describe '#save' do
    it 'return false if not valid' do
      application_qualification = create(:application_qualification)

      form = described_class.new
      expect(form.save(application_qualification)).to be(false)
    end

    it 'updates the existing qualification' do
      qualification = create(:gcse_qualification, subject: 'maths', qualification_type: 'missing')

      form = described_class.new(
        subject: 'maths',
        level: 'gcse',
        qualification_type: 'missing',
        not_completed_explanation: 'Still in progress',
        currently_completing_qualification: true,
      )

      form.save(qualification)

      qualification.reload

      expect(qualification.subject).to eq('maths')
      expect(qualification.level).to eq('gcse')
      expect(qualification.qualification_type).to eq('missing')
      expect(qualification.not_completed_explanation).to eq('Still in progress')
      expect(qualification.grade).to be_nil
      expect(qualification.award_year).to be_nil
      expect(qualification.institution_name).to be_nil
      expect(qualification.institution_country).to be_nil
    end
  end
end
