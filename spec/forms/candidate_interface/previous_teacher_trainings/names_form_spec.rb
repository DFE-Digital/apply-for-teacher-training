require 'rails_helper'

module CandidateInterface
  module PreviousTeacherTrainings
    RSpec.describe NamesForm, type: :model do
      subject(:form) do
        described_class.new(previous_teacher_training)
      end

      let(:previous_teacher_training) { create(:previous_teacher_training) }

      describe '#providers' do
        it 'returns an array of providers' do
          provider = create(:provider)
          create(:course, :open, provider:)

          expect(form.providers).to eq([provider])
        end
      end

      describe '#save' do
        context 'when provider name exist in DB' do
          it 'saves provider_name and id to previous_teacher_training' do
            provider = create(:provider)
            provider_name = provider.name
            form.provider_name = provider_name

            expect { form.save }.to change { previous_teacher_training.provider_name }
              .to(provider_name)
              .and change { previous_teacher_training.provider_id }.from(nil).to(provider.id)
          end
        end

        context 'when provider name does not exist in DB' do
          it 'saves only provider_name to previous_teacher_training' do
            provider_name = 'test name'
            form.provider_name = provider_name

            expect { form.save }.to change { previous_teacher_training.provider_name }
              .to(provider_name)
            expect(previous_teacher_training.provider_id).to be_nil
          end
        end

        context 'with invalid form' do
          it 'returns nil' do
            form.provider_name = nil

            expect(form.save).to be_nil
          end
        end
      end
    end
  end
end
