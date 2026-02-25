require 'rails_helper'

RSpec.describe GeneratePossiblePreviousTeacherTraining do
  include DfE::Bigquery::TestHelper

  let(:candidate) { build(:candidate, email_address: 'john_doe@example.com') }
  let!(:application_1) { create(:application_form, candidate:, first_name: 'john', last_name: 'doe', date_of_birth: '01/01/1990') }
  let!(:application_2) { create(:application_form, candidate:, first_name: 'johnny', last_name: 'doe', date_of_birth: '01/01/1990') }
  let!(:application_3) { create(:application_form, first_name: 'johnathan', last_name: 'doe', date_of_birth: '01/01/1990') }

  subject(:generate_pptt) { described_class.new(candidate) }

  before do
    stub_bigquery_non_disclosure_trainee_withdrawals_request
  end

  describe '.call' do
    subject(:call) { generate_pptt.call }

    it 'creates PossiblePreviousTeacherTraining records based on the BigQuery response' do
      expect { call }.to change { PossiblePreviousTeacherTraining.count }.by(1)
      possible_previous_teacher_training = PossiblePreviousTeacherTraining.last
      expect(possible_previous_teacher_training.candidate).to eq(candidate)
      expect(possible_previous_teacher_training.provider_name).to eq('The London Provider')
      expect(possible_previous_teacher_training.started_on).to eq(Date.parse('2024-09-01'))
      expect(possible_previous_teacher_training.ended_on).to eq(Date.parse('2025-01-01'))
      expect(possible_previous_teacher_training.provider).to be_nil
    end

    context 'when the provider code provided by bigquery matches the code of any existing provider' do
      let!(:existing_provider) { create(:provider, code: '1AB') }

      it 'creates PossiblePreviousTeacherTraining records associated with the provider' do
        expect { call }.to change { PossiblePreviousTeacherTraining.count }.by(1)
        possible_previous_teacher_training = PossiblePreviousTeacherTraining.last
        expect(possible_previous_teacher_training.provider).to eq(existing_provider)
      end
    end

    context 'when BigQuery returns multiple rows of data' do
      let(:rows) do
        [
          [
            { name: 'trn', type: 'STRING', value: '1234567' },
            { name: 'start_academic_year', type: 'INTEGER', value: '2025' },
            { name: 'trainee_id', type: 'INTEGER', value: '111111' },
            { name: 'created_at', type: 'DATETIME', value: DateTime.now.beginning_of_day.iso8601 },
            { name: 'first_name', type: 'STRING', value: 'John' },
            { name: 'last_name', type: 'STRING', value: 'Doe' },
            { name: 'date_of_birth', type: 'DATE', value: '01/01/1990' },
            { name: 'email', type: 'STRING', value: 'john_doe@example.com' },
            { name: 'training_route', type: 'STRING', value: 'provider_led_postgrad' },
            { name: 'trainee_start_date', type: 'DATE', value: '01/09/2024' },
            { name: 'training_route_category', type: 'STRING', value: 'pg_fee_funded' },
            { name: 'name', type: 'STRING', value: 'The London Provider' },
            { name: 'type', type: 'STRING', value: 'SCITT' },
            { name: 'id', type: 'STRING', value: '123' },
            { name: 'code', type: 'STRING', value: '1AB' },
            { name: 'ukprn', type: 'STRING', value: '1234567890' },
            { name: 'apply_sync_enabled', type: 'BOOLEAN', value: true },
            { name: 'education_phase', type: 'STRING', value: 'primary' },
            { name: 'allocation_subject', type: 'STRING', value: 'Primary' },
            { name: 'allocation_subject_id', type: 'STRING', value: '01' },
            { name: 'tad_subject', type: 'STRING', value: 'Primary' },
            { name: 'subject_one', type: 'STRING', value: 'primary teaching' },
            { name: 'subject_two', type: 'STRING', value: nil },
            { name: 'subject_three', type: 'STRING', value: nil },
            { name: 'min_age', type: 'STRING', value: '3' },
            { name: 'max_age', type: 'STRING', value: '7' },
            { name: 'uuid', type: 'STRING', value: 'abcd1234' },
            { name: 'category', type: 'STRING', value: ['does_not_want_to_become_a_teacher'] },
            { name: 'structured_reason', type: 'STRING', value: ['does_not_want_to_become_a_teacher'] },
            { name: 'free_text_reason', type: 'STRING', value: [] },
            { name: 'future_interest', type: 'STRING', value: nil },
            { name: 'trigger', type: 'STRING', value: nil },
            { name: 'date', type: 'DATE', value: '01/01/2025' },
          ],
          [
            { name: 'trn', type: 'STRING', value: '1234567' },
            { name: 'start_academic_year', type: 'INTEGER', value: '2024' },
            { name: 'trainee_id', type: 'INTEGER', value: '111111' },
            { name: 'created_at', type: 'DATETIME', value: DateTime.now.beginning_of_day.iso8601 },
            { name: 'first_name', type: 'STRING', value: 'Johnny' },
            { name: 'last_name', type: 'STRING', value: 'Doe' },
            { name: 'date_of_birth', type: 'DATE', value: '01/01/1990' },
            { name: 'email', type: 'STRING', value: 'jd@example.com' },
            { name: 'training_route', type: 'STRING', value: 'provider_led_postgrad' },
            { name: 'trainee_start_date', type: 'DATE', value: '01/09/2023' },
            { name: 'training_route_category', type: 'STRING', value: 'pg_fee_funded' },
            { name: 'name', type: 'STRING', value: 'The Brixton Provider' },
            { name: 'type', type: 'STRING', value: 'SCITT' },
            { name: 'id', type: 'STRING', value: '789' },
            { name: 'code', type: 'STRING', value: '2ZZ' },
            { name: 'ukprn', type: 'STRING', value: '1234567891' },
            { name: 'apply_sync_enabled', type: 'BOOLEAN', value: true },
            { name: 'education_phase', type: 'STRING', value: 'primary' },
            { name: 'allocation_subject', type: 'STRING', value: 'Primary' },
            { name: 'allocation_subject_id', type: 'STRING', value: '01' },
            { name: 'tad_subject', type: 'STRING', value: 'Primary' },
            { name: 'subject_one', type: 'STRING', value: 'primary teaching' },
            { name: 'subject_two', type: 'STRING', value: nil },
            { name: 'subject_three', type: 'STRING', value: nil },
            { name: 'min_age', type: 'STRING', value: '3' },
            { name: 'max_age', type: 'STRING', value: '7' },
            { name: 'uuid', type: 'STRING', value: 'abcd1234' },
            { name: 'category', type: 'STRING', value: ['does_not_want_to_become_a_teacher'] },
            { name: 'structured_reason', type: 'STRING', value: ['does_not_want_to_become_a_teacher'] },
            { name: 'free_text_reason', type: 'STRING', value: [] },
            { name: 'future_interest', type: 'STRING', value: nil },
            { name: 'trigger', type: 'STRING', value: nil },
            { name: 'date', type: 'DATE', value: '01/02/2024' },
          ],
        ]
      end

      before do
        stub_bigquery_non_disclosure_trainee_withdrawals_request(rows:)
      end

      it 'creates a PossiblePreviousTeacherTraining record per row' do
        expect { call }.to change { PossiblePreviousTeacherTraining.count }.by(2)
      end
    end

    context 'when the PossiblePreviousTeacherTraining record for that data already exists' do
      before do
        create(
          :possible_previous_teacher_training,
          candidate:,
          provider_name: 'The London Provider',
          started_on: '01/09/2024',
          ended_on: '01/01/2025',
        )
      end

      it 'does not create a PossiblePreviousTeacherTraining' do
        expect { call }.not_to(change { PossiblePreviousTeacherTraining.count })
      end
    end

    context 'when a PreviousTeacherTraining record for that data already exists within the timeframe' do
      let(:application_form) { create(:completed_application_form, candidate:) }

      context 'when the PreviousTeacherTraining record has no provider id' do
        let(:previous_teacher_training) do
          create(
            :previous_teacher_training,
            application_form:,
            provider_name: 'The London Provider',
            started_at: '01/09/2024',
            ended_at: '01/01/2025',
          )
        end

        before { previous_teacher_training }

        it 'does not create a PossiblePreviousTeacherTraining' do
          expect { call }.not_to(change { PossiblePreviousTeacherTraining.count })
        end
      end

      context 'when the PreviousTeacherTraining record has a provider id' do
        let(:existing_provider) { create(:provider, code: '1AB') }
        let(:previous_teacher_training) do
          create(
            :previous_teacher_training,
            application_form:,
            provider: existing_provider,
            provider_name: 'The London Provider',
            started_at: '01/09/2024',
            ended_at: '01/01/2025',
          )
        end

        before { previous_teacher_training }

        it 'does not create a PossiblePreviousTeacherTraining' do
          expect { call }.not_to(change { PossiblePreviousTeacherTraining.count })
        end
      end
    end
  end
end
