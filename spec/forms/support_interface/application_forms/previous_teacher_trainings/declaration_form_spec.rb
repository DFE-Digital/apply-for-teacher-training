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
      it 'returns false' do
        expect(form.save).to be(false)

        expect(form.errors).to include([''])
      end
    end

    context 'when '
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
