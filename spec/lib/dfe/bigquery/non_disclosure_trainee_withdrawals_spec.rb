require 'rails_helper'

RSpec.describe DfE::Bigquery::NonDisclosureTraineeWithdrawals do
  include DfE::Bigquery::TestHelper

  let(:candidate) { build(:candidate, email_address: 'john_doe@example.com') }
  let!(:application_1) { create(:application_form, candidate:, first_name: 'john', last_name: 'doe', date_of_birth: '01/01/1990') }
  let!(:application_2) { create(:application_form, candidate:, first_name: 'johnny', last_name: 'doe', date_of_birth: '01/01/1990') }
  let!(:application_3) { create(:application_form, first_name: 'johnathan', last_name: 'doe', date_of_birth: '01/01/1990') }
  let(:big_query_instance) { described_class.new(candidate:) }
  let(:rows) do
    [[
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
     { name: 'accredited_provider_name', type: 'STRING', value: 'The London Provider' },
     { name: 'accredited_provider_type', type: 'STRING', value: 'SCITT' },
     { name: 'accredited_provider_id', type: 'STRING', value: '123' },
     { name: 'accredited_provider_code', type: 'STRING', value: '1AB' },
     { name: 'accredited_provider_ukprn', type: 'STRING', value: '1234567890' },
     { name: 'accredited_provider_apply_sync_enabled', type: 'BOOLEAN', value: true },
     { name: 'course_education_phase', type: 'STRING', value: 'primary' },
     { name: 'course_allocation_subject', type: 'STRING', value: 'Primary' },
     { name: 'course_allocation_subject_id', type: 'STRING', value: '01' },
     { name: 'course_tad_subject', type: 'STRING', value: 'Primary' },
     { name: 'course_subject_one', type: 'STRING', value: 'primary teaching' },
     { name: 'course_subject_two', type: 'STRING', value: nil },
     { name: 'course_subject_three', type: 'STRING', value: nil },
     { name: 'course_min_age', type: 'STRING', value: '3' },
     { name: 'course_max_age', type: 'STRING', value: '7' },
     { name: 'course_uuid', type: 'STRING', value: 'abcd1234' },
     { name: 'withdraw_category', type: 'STRING', value: ["does_not_want_to_become_a_teacher"] },
     { name: 'withdraw_structured_reason', type: 'STRING', value: ["does_not_want_to_become_a_teacher"] },
     { name: 'withdraw_free_text_reason', type: 'STRING', value: [] },
     { name: 'withdraw_future_interest', type: 'STRING', value: nil },
     { name: 'withdraw_trigger', type: 'STRING', value: nil },
     { name: 'withdraw_date', type: 'DATE', value: '01/01/2025' },
    ]]
  end

  describe '.trainee_data' do
    subject(:trainee_data) { big_query_instance.trainee_data }

    let(:results) do
      [
        {
          trn: '1234567',
          start_academic_year: 2025,
          trainee_id: 111111,
          created_at: DateTime.now.beginning_of_day,
          first_name: 'John',
          last_name: 'Doe',
          date_of_birth: '1990-01-01',
          email: 'john_doe@example.com',
          training_route: 'provider_led_postgrad',
          trainee_start_date: '2024-09-01',
          training_route_category: 'pg_fee_funded' ,
          accredited_provider_name: 'The London Provider',
          accredited_provider_type: 'SCITT',
          accredited_provider_id: '123',
          accredited_provider_code: '1AB',
          accredited_provider_ukprn: '1234567890',
          accredited_provider_apply_sync_enabled: true,
          course_education_phase: 'primary',
          course_allocation_subject: 'Primary',
          course_allocation_subject_id: '01' ,
          course_tad_subject: 'Primary',
          course_subject_one: 'primary teaching',
          course_subject_two: nil,
          course_subject_three: nil,
          course_min_age: '3',
          course_max_age: '7',
          course_uuid: 'abcd1234',
          withdraw_category: ["does_not_want_to_become_a_teacher"],
          withdraw_structured_reason: ["does_not_want_to_become_a_teacher"],
          withdraw_free_text_reason: [],
          withdraw_future_interest: nil,
          withdraw_trigger: nil,
          withdraw_date: '2025-01-01',
        }
      ]
    end

    before do
      stub_bigquery_non_disclosure_trainee_withdrawals_request(rows:)
    end

    it 'returns the first result' do
      expect(trainee_data.as_json).to eq(results.as_json)
    end

    it 'provides the correct SQL' do
      allow(Google::Apis::BigqueryV2::QueryRequest).to receive(:new).and_call_original
      trainee_data
      expect(Google::Apis::BigqueryV2::QueryRequest).to have_received(:new).with(query: <<~SQL, timeout_ms: 10_000, use_legacy_sql: false)
        SELECT trn, start_academic_year, trainee_id, created_at, first_name, last_name, date_of_birth, email, training_route, training_route_category, trainee_start_date, accredited_provider.name, accredited_provider.type, accredited_provider.id, accredited_provider.code, accredited_provider.ukprn, accredited_provider.apply_sync_enabled, course.education_phase, course.allocation_subject, course.allocation_subject_id, course.tad_subject, course.subject_one, course.subject_two, course.subject_three, course.min_age, course.max_age, course.uuid, withdraw.category, withdraw.structured_reason, withdraw.free_text_reason, withdraw.future_interest, withdraw.trigger, withdraw.date
        FROM `1_key_tables.non_disclosure_trainee_withdrawals`
        WHERE email = john_doe@example.com OR first_name IN ("john", "johnny") AND last_name IN ("doe") AND date_of_birth = 1990-01-01
      SQL
    end

    it 'assigns the attributes for the non disclosure trainee withdrawals', :aggregate_failures do
      response = trainee_data.first
      expect(response.trn).to eq('1234567')
      expect(response.start_academic_year).to eq(2025)
      expect(response.trainee_id).to eq(111111)
      expect(response.created_at).to eq(DateTime.now.beginning_of_day)
      expect(response.first_name).to eq('John')
      expect(response.last_name).to eq('Doe')
      expect(response.date_of_birth).to eq(Date.parse('1990-01-01'))
      expect(response.email).to eq('john_doe@example.com')
      expect(response.training_route).to eq('provider_led_postgrad')
      expect(response.trainee_start_date).to eq(Date.parse('2024-09-01'))
      expect(response.training_route_category).to eq('pg_fee_funded')
      expect(response.accredited_provider_name).to eq('The London Provider')
      expect(response.accredited_provider_type).to eq('SCITT')
      expect(response.accredited_provider_id).to eq('123')
      expect(response.accredited_provider_code).to eq('1AB')
      expect(response.accredited_provider_ukprn).to eq('1234567890')
      expect(response.accredited_provider_apply_sync_enabled).to be(true)
      expect(response.course_education_phase).to eq('primary')
      expect(response.course_allocation_subject).to eq('Primary')
      expect(response.course_allocation_subject_id).to eq('01')
      expect(response.course_tad_subject).to eq('Primary')
      expect(response.course_subject_one).to eq('primary teaching')
      expect(response.course_subject_two).to be_nil
      expect(response.course_subject_three).to be_nil
      expect(response.course_min_age).to eq('3')
      expect(response.course_max_age).to eq('7')
      expect(response.course_uuid).to eq('abcd1234')
      expect(response.withdraw_category).to contain_exactly("does_not_want_to_become_a_teacher")
      expect(response.withdraw_structured_reason).to contain_exactly("does_not_want_to_become_a_teacher")
      expect(response.withdraw_free_text_reason).to eq([])
      expect(response.withdraw_future_interest).to be_nil
      expect(response.withdraw_trigger).to be_nil
      expect(response.withdraw_date).to eq(Date.parse('2025-01-01'))
    end

    context 'when the api returns no data for the candidate' do
      before do
        stub_bigquery_non_disclosure_trainee_withdrawals_request(rows: [])
      end

      it 'returns an empty array' do
        expect(trainee_data).to be_empty
      end
    end

    describe 'when the query returns nil for rows' do
      before do
        stub_bigquery_non_disclosure_trainee_withdrawals_request(result: false)
      end

      it 'fails silently' do
        trainee_data
      end
    end

    describe 'when there is an error' do
      context 'when there is more than one page' do
        before do
          stub_bigquery_non_disclosure_trainee_withdrawals_request(page_token: true)
        end

        it 'raises an error' do
          expect { trainee_data }.to raise_error(DfE::Bigquery::Relation::MorePagesError)
        end
      end

      context 'when the query job does not complete in time' do
        before do
          stub_bigquery_non_disclosure_trainee_withdrawals_request(job_complete: false)
        end

        it 'raises an error' do
          expect { trainee_data }.to raise_error(DfE::Bigquery::Relation::JobIncompleteError)
        end
      end

      context 'when an unhandled type is returned' do
        before do
          stub_bigquery_non_disclosure_trainee_withdrawals_request(rows: [[
                                                                            { name: 'some_value', type: 'COFFEE', value: '☕' },
                                                                          ]])
        end

        it 'raises an error' do
          expect { trainee_data }.to raise_error(
                                            DfE::Bigquery::Relation::UnknownTypeError
                                          ).with_message("cannot parse this type of value: 'COFFEE'")
        end
      end
    end
  end

  describe described_class::Result do
    let(:result) { described_class.new({ first_name: 'John', last_name: 'Doe' }) }

    before do
      stub_bigquery_non_disclosure_trainee_withdrawals_request(rows:)
    end

    describe '#attributes' do
      it 'returns the correct #attributes' do
        expect(result.attributes).to include({'first_name' => 'John', 'last_name' => 'Doe', 'email' => nil})
      end
    end
  end
end
