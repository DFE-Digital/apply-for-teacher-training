require 'rails_helper'

RSpec.describe SupportInterface::ApplicationForms::EditBecomingATeacherForm, type: :model, with_audited: true do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:becoming_a_teacher) }
    it { is_expected.to validate_presence_of(:audit_comment) }

    valid_text = Faker::Lorem.sentence(word_count: 600)
    invalid_text = Faker::Lorem.sentence(word_count: 601)

    it { is_expected.to allow_value(valid_text).for(:becoming_a_teacher) }
    it { is_expected.not_to allow_value(invalid_text).for(:becoming_a_teacher) }
  end

  describe '.build_from_application' do
    it 'creates an object based on the provided ApplicationForm' do
      application_form = create(:application_form, becoming_a_teacher: 'I really want to teach.')
      form = described_class.build_from_application(
        application_form,
      )

      expect(form.becoming_a_teacher).to eq 'I really want to teach.'
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
      form = described_class.new(becoming_a_teacher: 'I really want to teach.', audit_comment: 'It was on a zendesk ticket.')

      form.save(application_form)

      expect(application_form.becoming_a_teacher).to eq 'I really want to teach.'
      expect(application_form.audits.last.comment).to eq 'It was on a zendesk ticket.'
    end

    it 'updates the associated ApplicationChoice if valid' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, application_form: application_form)
      form = described_class.new(becoming_a_teacher: 'I really want to teach.', audit_comment: 'It was on a zendesk ticket.')

      form.save(application_form)

      expect(application_choice.reload.personal_statement).to eq 'I really want to teach.'
      expect(application_form.becoming_a_teacher).to eq 'I really want to teach.'
      expect(application_form.audits.last.comment).to eq 'It was on a zendesk ticket.'
    end

    it 'when saving the records fails' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, application_form: application_form)
      form = described_class.new(becoming_a_teacher: 'I really want to teach.', audit_comment: 'It was on a zendesk ticket.')

      allow(application_form).to receive(:update).and_return(false)
      result = form.save(application_form)

      expect(application_choice.reload.personal_statement).to be_nil
      expect(application_form.becoming_a_teacher).to be_nil
      expect(application_form.audits.last.comment).to be_nil
      expect(result).to be_nil
    end
  end
end
