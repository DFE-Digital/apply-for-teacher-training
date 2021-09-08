require 'rails_helper'

RSpec.describe CandidateInterface::GcseNotCompletedForm, type: :model do
  describe 'validations' do
    valid_text = Faker::Lorem.sentence(word_count: 200)
    long_text = Faker::Lorem.sentence(word_count: 201)

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
      expect(form.save(application_qualification)).to eq(false)
    end

    it 'creates a new qualification if valid' do
      qualification = create(:application_qualification)

      form = described_class.new(subject: 'maths', level: 'gcse', qualification_type: 'missing', not_completed_explanation: 'Still in progress')

      form.save(qualification)

      expect(form.subject).to eq('maths')
      expect(form.level).to eq('gcse')
      expect(form.qualification_type).to eq('missing')
      expect(form.not_completed_explanation).to eq('Still in progress')
    end
  end
end
