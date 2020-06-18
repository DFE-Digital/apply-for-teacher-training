require 'rails_helper'

RSpec.describe CandidateInterface::SubjectKnowledgeForm, type: :model do
  let(:data) do
    {
      subject_knowledge: Faker::Lorem.paragraph_by_chars(number: 200),
    }
  end

  let(:form_data) do
    {
      subject_knowledge: data[:subject_knowledge],
    }
  end

  describe '.build_from_application' do
    it 'creates an object based on the provided ApplicationForm' do
      application_form = ApplicationForm.new(data)
      subject_knowledge = CandidateInterface::SubjectKnowledgeForm.build_from_application(
        application_form,
      )

      expect(subject_knowledge).to have_attributes(form_data)
    end
  end

  describe '#save' do
    it 'returns false if not valid' do
      subject_knowledge = CandidateInterface::SubjectKnowledgeForm.new

      expect(subject_knowledge.save(ApplicationForm.new)).to eq(false)
    end

    it 'updates the provided ApplicationForm if valid' do
      application_form = FactoryBot.create(:application_form)
      subject_knowledge = CandidateInterface::SubjectKnowledgeForm.new(form_data)

      expect(subject_knowledge.save(application_form)).to eq(true)
      expect(application_form).to have_attributes(data)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:subject_knowledge) }

    valid_text = Faker::Lorem.sentence(word_count: 400)
    invalid_text = Faker::Lorem.sentence(word_count: 401)

    it { is_expected.to allow_value(valid_text).for(:subject_knowledge) }
    it { is_expected.not_to allow_value(invalid_text).for(:subject_knowledge) }
  end
end
