require 'rails_helper'

RSpec.describe VendorAPI::ApplicationPresenter, version: '1.7' do
  subject(:application_json) { described_class.new('1.7', application_choice).as_json }

  describe '#previous_teacher_training' do
    context 'when previous_teacher_training exists' do
      let(:application_form) { create(:application_form, :completed) }
      let(:application_choice) { create(:application_choice, application_form:) }

      it 'returns the previous_teacher_training data' do
        previous_teacher_training = application_form.published_previous_teacher_training

        expect(application_json.dig(:attributes, :previous_teacher_training)).to eq([
          {
            started: true,
            provider_name: previous_teacher_training.provider_name,
            started_at: previous_teacher_training.started_at.iso8601,
            ended_at: previous_teacher_training.ended_at.iso8601,
            details: previous_teacher_training.details,
          },
        ])
      end
    end

    context 'when previous_teacher_training does not exist' do
      let(:application_form) { create(:application_form, :not_started_previous_teacher_training) }
      let(:application_choice) { create(:application_choice, application_form:) }

      it 'returns a default previous_teacher_training object with started: false' do
        expect(application_json.dig(:attributes, :previous_teacher_training)).to eq([
          {
            started: false,
            provider_name: nil,
            started_at: nil,
            ended_at: nil,
            details: nil,
          },
        ])
      end
    end
  end
end
