require 'rails_helper'

RSpec.describe SupportInterface::ApplicationForms::PreviousTeacherTrainings::RemoveForm, type: :model do
  subject(:form) { described_class.new(previous_teacher_training) }

  let(:previous_teacher_training) { create(:previous_teacher_training, :published) }
  let(:application_form) { previous_teacher_training.application_form }

  describe '#destroy' do
    context 'when there is more than one published previous teacher training' do
      let(:second_previous_teacher_training) { create(:previous_teacher_training, :published, application_form:) }

      before { second_previous_teacher_training }

      it 'destroys the previous teacher training' do
        expect { form.destroy }.to change(PreviousTeacherTraining, :count).by(-1)
        expect(application_form.previous_teacher_trainings).to contain_exactly(second_previous_teacher_training)
      end
    end

    context 'when there is only one published previous teacher training' do
      before { previous_teacher_training }

      it 'does not destroy the previous teacher training, but sets started to "no" and nullifies the attributes' do
        expect { form.destroy }.not_to change(PreviousTeacherTraining, :count)

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
end
