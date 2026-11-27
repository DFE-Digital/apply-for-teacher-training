require 'rails_helper'

RSpec.describe SupportInterface::ApplicationForms::PreviousTeacherTrainings::DeclarationForm, type: :model do
  include Rails.application.routes.url_helpers

  subject(:form) { described_class.new(previous_teacher_training) }

  let(:previous_teacher_training) { create(:previous_teacher_training) }
  let(:application_form) { previous_teacher_training.application_form }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:started) }
    it { is_expected.to validate_presence_of(:audit_comment) }
  end

  describe '#options' do
    it 'returns the form options' do
      expect(form.options).to eq(
        [
          SupportInterface::ApplicationForms::PreviousTeacherTrainings::DeclarationForm::Started.new(value: 'yes', name: 'Yes'),
          SupportInterface::ApplicationForms::PreviousTeacherTrainings::DeclarationForm::Started.new(value: 'no', name: 'No'),
        ],
      )
    end
  end

  describe 'save' do
    context 'when the attributes are not valid' do
      before do
        form.assign_attributes(started: nil, audit_comment: nil)
      end

      it 'returns false' do
        expect(form.save).to be(false)

        expect(form.errors[:started]).to eq(['Select whether the candidate has started a teacher training course before'])
        expect(form.errors[:audit_comment]).to eq(['Enter a Zendesk ticket URL'])
      end
    end

    context 'when the previous teacher training is assigned to not started' do
      before do
        form.assign_attributes(started: 'no', audit_comment: 'https://becomingateacher.zendesk.com/agent/tickets/12345')
      end

      it 'returns true, and changes the previous teacher training to "no" (not started) and nullifies the attributes' do
        expect(form.save).to be(true)
        previous_teacher_training.reload

        expect(previous_teacher_training.started).to eq('no')
        expect(previous_teacher_training.provider_name).to be_nil
        expect(previous_teacher_training.provider_id).to be_nil
        expect(previous_teacher_training.started_at).to be_nil
        expect(previous_teacher_training.ended_at).to be_nil
        expect(previous_teacher_training.details).to be_nil
      end
    end

    context 'when the previous teacher training is assigned to started' do
      let(:previous_teacher_training) { create(:previous_teacher_training, :not_started) }

      before do
        form.assign_attributes(started: 'yes', audit_comment: 'https://becomingateacher.zendesk.com/agent/tickets/12345')
      end

      it 'returns true, and the previous teacher training is not changed' do
        expect(form.save).to be(true)
        previous_teacher_training.reload

        expect(previous_teacher_training.started).to eq('no')
        expect(previous_teacher_training.provider_name).to be_nil
        expect(previous_teacher_training.provider_id).to be_nil
        expect(previous_teacher_training.started_at).to be_nil
        expect(previous_teacher_training.ended_at).to be_nil
        expect(previous_teacher_training.details).to be_nil
      end
    end
  end

  describe '.next_path' do
    context 'when the previous teacher training is started' do
      context 'when the provider name is blank' do
        let(:previous_teacher_training) { create(:previous_teacher_training, provider_name: nil) }

        it 'returns the edit previous teacher training path' do
          expect(form.next_path).to eq(support_interface_application_form_edit_teacher_training_previous_teacher_trainings_path(application_form, previous_teacher_training))
        end
      end

      context 'when the previous teacher training details assigned' do
        it 'returns the application form path' do
          expect(form.next_path).to eq(support_interface_application_form_path(application_form))
        end
      end
    end

    context 'when the previous teacher training is not started' do
      it 'returns the application form path' do
        expect(form.next_path).to eq(support_interface_application_form_path(application_form))
      end
    end
  end
end
