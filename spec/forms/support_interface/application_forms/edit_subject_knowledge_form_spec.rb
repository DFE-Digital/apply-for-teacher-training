require 'rails_helper'

RSpec.describe SupportInterface::ApplicationForms::EditSubjectKnowledgeForm, :with_audited, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:subject_knowledge) }
    it { is_expected.to validate_presence_of(:audit_comment) }

    valid_text = Faker::Lorem.sentence(word_count: 400)
    invalid_text = Faker::Lorem.sentence(word_count: 401)

    it { is_expected.to allow_value(valid_text).for(:subject_knowledge) }
    it { is_expected.not_to allow_value(invalid_text).for(:subject_knowledge) }
  end

  describe '.build_from_application' do
    it 'creates an object based on the provided ApplicationForm' do
      application_form = create(:application_form, subject_knowledge: 'I really want to teach.')
      form = described_class.build_from_application(
        application_form,
      )

      expect(form.subject_knowledge).to eq 'I really want to teach.'
    end
  end

  describe '#save' do
    it 'returns false if not valid' do
      application_form = double
      form = described_class.new

      expect(form.save(application_form)).to be(false)
    end

    it 'updates the provided ApplicationForm if valid' do
      application_form = create(:application_form)
      form = described_class.new(subject_knowledge: 'I really want to teach.', audit_comment: 'It was on a zendesk ticket.')

      form.save(application_form)

      expect(application_form.subject_knowledge).to eq 'I really want to teach.'
      expect(application_form.audits.last.comment).to eq 'It was on a zendesk ticket.'
    end
  end
end
