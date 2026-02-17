module DfE
  module Bigquery
    module TestHelper
      def stub_bigquery_application_metrics_request(rows: nil, job_complete: true, page_token: nil, result: true)
        bigquery_client = instance_double(Google::Apis::BigqueryV2::BigqueryService)
        allow(DfE::Bigquery).to receive(:client).and_return(bigquery_client)
        allow(bigquery_client).to receive(:query_job).and_return(stubbed_bigquery_application_metrics_response(rows:, job_complete:, page_token:, result:))
      end

      def stub_bigquery_application_metrics_by_provider_request(rows: nil, job_complete: true, page_token: nil, result: true)
        bigquery_client = instance_double(Google::Apis::BigqueryV2::BigqueryService)
        allow(DfE::Bigquery).to receive(:client).and_return(bigquery_client)
        allow(bigquery_client).to receive(:query_job).and_return(stubbed_bigquery_application_metrics_by_provider_response(rows:, job_complete:, page_token:, result:))
      end

      def stub_bigquery_regional_provider_metrics_request(rows: nil, job_complete: true, page_token: nil, result: true)
        bigquery_client = instance_double(Google::Apis::BigqueryV2::BigqueryService)
        allow(DfE::Bigquery).to receive(:client).and_return(bigquery_client)
        allow(bigquery_client).to receive(:query_job).and_return(stub_bigquery_regional_provider_metrics_response(rows:, job_complete:, page_token:, result:))
      end

      def stub_bigquery_regional_edi_request(rows: nil, job_complete: true, page_token: nil, result: true)
        bigquery_client = instance_double(Google::Apis::BigqueryV2::BigqueryService)
        allow(DfE::Bigquery).to receive(:client).and_return(bigquery_client)
        allow(bigquery_client).to receive(:query_job).and_return(stub_bigquery_regional_edi_report_response(rows:, job_complete:, page_token:, result:))
      end

      def stub_bigquery_national_edi_request(rows: nil, job_complete: true, page_token: nil, result: true)
        bigquery_client = instance_double(Google::Apis::BigqueryV2::BigqueryService)
        allow(DfE::Bigquery).to receive(:client).and_return(bigquery_client)
        allow(bigquery_client).to receive(:query_job).and_return(stub_bigquery_national_edi_report_response(rows:, job_complete:, page_token:, result:))
      end

      def stub_bigquery_provider_edi_request(rows: nil, job_complete: true, page_token: nil, result: true)
        bigquery_client = instance_double(Google::Apis::BigqueryV2::BigqueryService)
        allow(DfE::Bigquery).to receive(:client).and_return(bigquery_client)
        allow(bigquery_client).to receive(:query_job).and_return(stub_bigquery_provider_edi_report_response(rows:, job_complete:, page_token:, result:))
      end

      def stub_bigquery_non_disclosure_trainee_withdrawals_request(rows: nil, job_complete: true, page_token: nil, result: true)
        bigquery_client = instance_double(Google::Apis::BigqueryV2::BigqueryService)
        allow(DfE::Bigquery).to receive(:client).and_return(bigquery_client)
        allow(bigquery_client).to receive(:query_job).and_return(stub_bigquery_non_disclosure_trainee_withdrawals_response(rows:, job_complete:, page_token:, result:))
      end

      # @param row [nil|Row|'nil']
      #   When nil, it returns a default response
      #   When Row it returns the values defined in the Row
      #   When 'nil' it returns literal nil
      # @param job_complete [Boolean] Is the response populated with the query result?
      # @param page_token [String] If present, there is a next page that must be fetched
      # @param result [Boolean] Does the response return values?
      #
      def stubbed_bigquery_application_metrics_response(rows: nil, job_complete: nil, page_token: nil, result: true)
        return BigqueryStubs.stub_response(rows:, job_complete:, page_token:, result:) unless result

        return BigqueryStubs.stub_response(rows:, job_complete:, page_token:, result:) if rows

        BigqueryStubs.stub_response(rows: [[
          { name: 'cycle_week', type: 'INTEGER', value: '7' },
          { name: 'first_date_in_week', type: 'DATE', value: '2023-11-13' },
          { name: 'last_date_in_week', type: 'DATE', value: '2023-11-19' },
          { name: 'nonsubject_filter', type: 'INTEGER', value: '21' },
          { name: 'number_of_candidates_submitted_to_date', type: 'INTEGER', value: '400' },
          { name: 'number_of_candidates_submitted_to_same_date_previous_cycle', type: 'INTEGER', value: '200' },
          { name: 'number_of_candidates_who_did_not_meet_any_offer_conditions_this_cycle_to_date', type: 'INTEGER', value: '30' },
          { name: 'number_of_candidates_who_did_not_meet_any_offer_conditions_this_cycle_to_same_date_previous_cycle', type: 'INTEGER', value: '15' },
          { name: 'number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date', type: 'INTEGER', value: '100' },
          { name: 'number_of_candidates_who_had_all_applications_rejected_this_cycle_to_same_date_previous_cycle', type: 'INTEGER', value: '50' },
          { name: 'number_of_candidates_with_all_accepted_offers_withdrawn_this_cycle_to_date', type: 'INTEGER', value: '200' },
          { name: 'number_of_candidates_with_all_accepted_offers_withdrawn_this_cycle_to_same_date_previous_cycle', type: 'INTEGER', value: '100' },
          { name: 'number_of_candidates_with_deferred_offers_from_this_cycle_to_date', type: 'INTEGER', value: '0' },
          { name: 'number_of_candidates_with_deferred_offers_from_this_cycle_to_same_date_previous_cycle', type: 'INTEGER', value: '0' },
          { name: 'number_of_candidates_with_offers_to_date', type: 'INTEGER', value: '598' },
          { name: 'number_of_candidates_with_offers_to_same_date_previous_cycle', type: 'INTEGER', value: nil },
          { name: 'number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date', type: 'INTEGER', value: '285' },
          { name: 'number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_same_date_previous_cycle', type: 'INTEGER', value: '213' },
          { name: 'number_of_candidates_accepted_to_date', type: 'INTEGER', value: '20' },
          { name: 'number_of_candidates_accepted_to_same_date_previous_cycle', type: 'INTEGER', value: '10' },
        ]], job_complete:, page_token:, result:)
      end

      def stubbed_bigquery_application_metrics_by_provider_response(rows: nil, job_complete: nil, page_token: nil, result: true)
        return BigqueryStubs.stub_response(rows:, result:) if rows

        BigqueryStubs.stub_response(rows: [[
          { name: 'id', type: 'INTEGER', value: '1337' },
          { name: 'cycle_week', type: 'INTEGER', value: '18' },
          { name: 'recruitment_cycle_year', type: 'INTEGER', value: '2024' },
          { name: 'nonprovider_filter', type: 'STRING', value: 'Level' },
          { name: 'nonprovider_filter_category', type: 'STRING', value: 'Primary' },
          { name: 'number_of_candidates_submitted_to_date', type: 'INTEGER', value: '100' },
          { name: 'number_of_candidates_submitted_to_same_date_previous_cycle', type: 'INTEGER', value: '200' },
          { name: 'number_of_candidates_submitted_to_date_as_proportion_of_last_cycle', type: 'FLOAT', value: '0.5' },
          { name: 'number_of_candidates_with_offers_to_date', type: 'INTEGER', value: '10' },
          { name: 'number_of_candidates_with_offers_to_same_date_previous_cycle', type: 'INTEGER', value: '5' },
          { name: 'number_of_candidates_with_offers_to_date_as_proportion_of_last_cycle', type: 'FLOAT', value: '2.0' },
          { name: 'offer_rate_to_date', type: 'INTEGER', value: 'nil' },
          { name: 'offer_rate_to_same_date_previous_cycle', type: 'INTEGER', value: 'nil' },
          { name: 'number_of_candidates_accepted_to_date', type: 'INTEGER', value: '1' },
          { name: 'number_of_candidates_accepted_to_same_date_previous_cycle', type: 'INTEGER', value: '10' },
          { name: 'number_of_candidates_accepted_to_date_as_proportion_of_last_cycle', type: 'FLOAT', value: '0.1' },
          { name: 'number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date', type: 'INTEGER', value: '12' },
          { name: 'number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_same_date_previous_cycle', type: 'INTEGER', value: '12' },
          { name: 'number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date_as_proportion_of_last_cycle', type: 'INTEGER', value: '0' },
          { name: 'number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date', type: 'INTEGER', value: '12' },
          { name: 'number_of_candidates_who_had_all_applications_rejected_this_cycle_to_same_date_previous_cycle', type: 'INTEGER', value: '12' },
          { name: 'number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date_as_proportion_of_last_cycle', type: 'INTEGER', value: '0' },
          { name: 'number_of_candidates_who_had_an_inactive_application_this_cycle_to_date', type: 'INTEGER', value: '12' },
          { name: 'number_of_candidates_who_had_an_inactive_application_this_cycle_to_date_as_proportion_of_submitted_candidates', type: 'INTEGER', value: '12' },
        ]], job_complete:, page_token:, result:)
      end

      def stub_bigquery_regional_provider_metrics_response(rows: nil, job_complete: nil, page_token: nil, result: true)
        return BigqueryStubs.stub_response(rows:, result:) if rows

        BigqueryStubs.stub_response(rows: [[
          { name: 'nonregion_filter', type: 'STRING', value: 'Music' },
          { name: 'nonregion_filter_category', type: 'STRING', value: 'Secondary subject' },
          { name: 'cycle_week', type: 'INTEGER', value: 16 },
          { name: 'recruitment_cycle_year', type: 'INTEGER', value: 2026 },
          { name: 'region_filter', type: 'STRING', value: 'South West (England)' },
          { name: 'number_of_candidates_submitted_to_date', type: 'INTEGER', value: 21 },
          { name: 'number_of_candidates_submitted_to_same_date_previous_cycle', type: 'INTEGER', value: 26 },
          { name: 'number_of_candidates_submitted_to_date_as_proportion_of_last_cycle', type: 'FLOAT', value: 0.8 },
          { name: 'number_of_candidates_with_offers_to_date', type: 'INTEGER', value: 9 },
          { name: 'number_of_candidates_with_offers_to_same_date_previous_cycle', type: 'INTEGER', value: 7 },
          { name: 'number_of_candidates_with_offers_to_date_as_proportion_of_last_cycle', type: 'FLOAT', value: 1.2 },
          { name: 'offer_rate_to_date', type: 'FLOAT', value: 0.4 },
          { name: 'offer_rate_to_same_date_previous_cycle', type: 'FLOAT', value: 0.2 },
          { name: 'number_of_candidates_accepted_to_date', type: 'INTEGER', value: 8 },
          { name: 'number_of_candidates_accepted_to_same_date_previous_cycle', type: 'INTEGER', value: 4 },
          { name: 'number_of_candidates_accepted_to_date_as_proportion_of_last_cycle', type: 'FLOAT', value: 2.0 },
          { name: 'number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date', type: 'INTEGER', value: 1 },
          { name: 'number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_same_date_previous_cycle', type: 'INTEGER', value: 0 },
          { name: 'number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date_as_proportion_of_last_cycle', value: nil },
          { name: 'number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date', type: 'INTEGER', value: 3 },
          { name: 'number_of_candidates_who_had_all_applications_rejected_this_cycle_to_same_date_previous_cycle', type: 'INTEGER', value: 5 },
          { name: 'number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date_as_proportion_of_last_cycle', type: 'FLOAT', value: 0.6 },
          { name: 'number_of_candidates_who_had_an_inactive_application_this_cycle_to_date', type: 'INTEGER', value: 2 },
          { name: 'number_of_candidates_who_had_an_inactive_application_this_cycle_to_date_as_proportion_of_submitted_candidates', type: 'FLOAT', value: 0.0 },
          { name: 'number_of_candidates_who_had_an_inactive_application_last_cycle_to_date_as_proportion_of_submitted_candidates_last_cycle', type: 'FLOAT', value: 0.0 },
        ]], job_complete:, page_token:, result:)
      end

      def stub_bigquery_regional_edi_report_response(rows: nil, job_complete: nil, page_token: nil, result: true)
        return BigqueryStubs.stub_response(rows:, result:) if rows

        BigqueryStubs.stub_response(rows: [[
          { name: 'nonregion_filter', type: 'STRING', value: 'Prefer not to say' },
          { name: 'nonregion_filter_category', type: 'STRING', value: 'Sex' },
          { name: 'cycle_week', type: 'INTEGER', value: 18 },
          { name: 'recruitment_cycle_year', type: 'INTEGER', value: 2026 },
          { name: 'region_filter', type: 'STRING', value: 'London' },
          { name: 'number_of_candidates_submitted_to_date', type: 'INTEGER', value: 21 },
          { name: 'number_of_candidates_submitted_to_same_date_previous_cycle', type: 'INTEGER', value: 26 },
          { name: 'number_of_candidates_submitted_to_date_as_proportion_of_last_cycle', type: 'FLOAT', value: 0.8 },
          { name: 'number_of_candidates_with_offers_to_date', type: 'INTEGER', value: 9 },
          { name: 'number_of_candidates_with_offers_to_same_date_previous_cycle', type: 'INTEGER', value: 7 },
          { name: 'number_of_candidates_with_offers_to_date_as_proportion_of_last_cycle', type: 'FLOAT', value: 1.2 },
          { name: 'offer_rate_to_date', type: 'FLOAT', value: 0.4 },
          { name: 'offer_rate_to_same_date_previous_cycle', type: 'FLOAT', value: 0.2 },
          { name: 'number_of_candidates_accepted_to_date', type: 'INTEGER', value: 8 },
          { name: 'number_of_candidates_accepted_to_same_date_previous_cycle', type: 'INTEGER', value: 4 },
          { name: 'number_of_candidates_accepted_to_date_as_proportion_of_last_cycle', type: 'FLOAT', value: 2.0 },
          { name: 'number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date', type: 'INTEGER', value: 1 },
          { name: 'number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_same_date_previous_cycle', type: 'INTEGER', value: 0 },
          { name: 'number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date_as_proportion_of_last_cycle', value: nil },
          { name: 'number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date', type: 'INTEGER', value: 3 },
          { name: 'number_of_candidates_who_had_all_applications_rejected_this_cycle_to_same_date_previous_cycle', type: 'INTEGER', value: 5 },
          { name: 'number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date_as_proportion_of_last_cycle', type: 'FLOAT', value: 0.6 },
          { name: 'number_of_candidates_who_had_an_inactive_application_this_cycle_to_date', type: 'INTEGER', value: 2 },
          { name: 'number_of_candidates_who_had_an_inactive_application_this_cycle_to_date_as_proportion_of_submitted_candidates', type: 'FLOAT', value: 0.0 },
          { name: 'number_of_candidates_who_had_an_inactive_application_last_cycle_to_date_as_proportion_of_submitted_candidates_last_cycle', type: 'FLOAT', value: 0.0 },
        ]], job_complete:, page_token:, result:)
      end

      def stub_bigquery_national_edi_report_response(rows: nil, job_complete: nil, page_token: nil, result: true)
        return BigqueryStubs.stub_response(rows:, result:) if rows

        BigqueryStubs.stub_response(rows: [[
          { name: 'nonprovider_filter', type: 'STRING', value: 'Prefer not to say' },
          { name: 'nonprovider_filter_category', type: 'STRING', value: 'Sex' },
          { name: 'cycle_week', type: 'INTEGER', value: 18 },
          { name: 'recruitment_cycle_year', type: 'INTEGER', value: 2026 },
          { name: 'id', type: 'INTEGER', value: nil },
          { name: 'region_filter', type: 'STRING', value: 'South West (England)' },
          { name: 'number_of_candidates_submitted_to_date', type: 'INTEGER', value: 21 },
          { name: 'number_of_candidates_submitted_to_same_date_previous_cycle', type: 'INTEGER', value: 26 },
          { name: 'number_of_candidates_submitted_to_date_as_proportion_of_last_cycle', type: 'FLOAT', value: 0.8 },
          { name: 'number_of_candidates_with_offers_to_date', type: 'INTEGER', value: 9 },
          { name: 'number_of_candidates_with_offers_to_same_date_previous_cycle', type: 'INTEGER', value: 7 },
          { name: 'number_of_candidates_with_offers_to_date_as_proportion_of_last_cycle', type: 'FLOAT', value: 1.2 },
          { name: 'offer_rate_to_date', type: 'FLOAT', value: 0.4 },
          { name: 'offer_rate_to_same_date_previous_cycle', type: 'FLOAT', value: 0.2 },
          { name: 'number_of_candidates_accepted_to_date', type: 'INTEGER', value: 8 },
          { name: 'number_of_candidates_accepted_to_same_date_previous_cycle', type: 'INTEGER', value: 4 },
          { name: 'number_of_candidates_accepted_to_date_as_proportion_of_last_cycle', type: 'FLOAT', value: 2.0 },
          { name: 'number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date', type: 'INTEGER', value: 1 },
          { name: 'number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_same_date_previous_cycle', type: 'INTEGER', value: 0 },
          { name: 'number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date_as_proportion_of_last_cycle', value: nil },
          { name: 'number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date', type: 'INTEGER', value: 3 },
          { name: 'number_of_candidates_who_had_all_applications_rejected_this_cycle_to_same_date_previous_cycle', type: 'INTEGER', value: 5 },
          { name: 'number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date_as_proportion_of_last_cycle', type: 'FLOAT', value: 0.6 },
          { name: 'number_of_candidates_who_had_an_inactive_application_this_cycle_to_date', type: 'INTEGER', value: 2 },
          { name: 'number_of_candidates_who_had_an_inactive_application_this_cycle_to_date_as_proportion_of_submitted_candidates', type: 'FLOAT', value: 0.0 },
          { name: 'number_of_candidates_who_had_an_inactive_application_last_cycle_to_date_as_proportion_of_submitted_candidates_last_cycle', type: 'FLOAT', value: 0.0 },
        ]], job_complete:, page_token:, result:)
      end

      def stub_bigquery_provider_edi_report_response(rows: nil, job_complete: nil, page_token: nil, result: true)
        return BigqueryStubs.stub_response(rows:, result:) if rows

        BigqueryStubs.stub_response(rows: [[
          { name: 'nonprovider_filter', type: 'STRING', value: 'Prefer not to say' },
          { name: 'nonprovider_filter_category', type: 'STRING', value: 'Sex' },
          { name: 'cycle_week', type: 'INTEGER', value: 18 },
          { name: 'recruitment_cycle_year', type: 'INTEGER', value: 2026 },
          { name: 'id', type: 'INTEGER', value: 1 },
          { name: 'region_filter', type: 'STRING', value: 'South West (England)' },
          { name: 'number_of_candidates_submitted_to_date', type: 'INTEGER', value: 21 },
          { name: 'number_of_candidates_submitted_to_same_date_previous_cycle', type: 'INTEGER', value: 26 },
          { name: 'number_of_candidates_submitted_to_date_as_proportion_of_last_cycle', type: 'FLOAT', value: 0.8 },
          { name: 'number_of_candidates_with_offers_to_date', type: 'INTEGER', value: 9 },
          { name: 'number_of_candidates_with_offers_to_same_date_previous_cycle', type: 'INTEGER', value: 7 },
          { name: 'number_of_candidates_with_offers_to_date_as_proportion_of_last_cycle', type: 'FLOAT', value: 1.2 },
          { name: 'offer_rate_to_date', type: 'FLOAT', value: 0.4 },
          { name: 'offer_rate_to_same_date_previous_cycle', type: 'FLOAT', value: 0.2 },
          { name: 'number_of_candidates_accepted_to_date', type: 'INTEGER', value: 8 },
          { name: 'number_of_candidates_accepted_to_same_date_previous_cycle', type: 'INTEGER', value: 4 },
          { name: 'number_of_candidates_accepted_to_date_as_proportion_of_last_cycle', type: 'FLOAT', value: 2.0 },
          { name: 'number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date', type: 'INTEGER', value: 1 },
          { name: 'number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_same_date_previous_cycle', type: 'INTEGER', value: 0 },
          { name: 'number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date_as_proportion_of_last_cycle', value: nil },
          { name: 'number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date', type: 'INTEGER', value: 3 },
          { name: 'number_of_candidates_who_had_all_applications_rejected_this_cycle_to_same_date_previous_cycle', type: 'INTEGER', value: 5 },
          { name: 'number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date_as_proportion_of_last_cycle', type: 'FLOAT', value: 0.6 },
          { name: 'number_of_candidates_who_had_an_inactive_application_this_cycle_to_date', type: 'INTEGER', value: 2 },
          { name: 'number_of_candidates_who_had_an_inactive_application_this_cycle_to_date_as_proportion_of_submitted_candidates', type: 'FLOAT', value: 0.0 },
          { name: 'number_of_candidates_who_had_an_inactive_application_last_cycle_to_date_as_proportion_of_submitted_candidates_last_cycle', type: 'FLOAT', value: 0.0 },
        ]], job_complete:, page_token:, result:)
      end

      def stub_bigquery_non_disclosure_trainee_withdrawals_response(rows: nil, job_complete: nil, page_token: nil, result: true)
        return BigqueryStubs.stub_response(rows:, result:) if rows

        BigqueryStubs.stub_response(rows: [[
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
          { name: 'withdraw_category', type: 'STRING', value: ['does_not_want_to_become_a_teacher'] },
          { name: 'withdraw_structured_reason', type: 'STRING', value: ['does_not_want_to_become_a_teacher'] },
          { name: 'withdraw_free_text_reason', type: 'STRING', value: [] },
          { name: 'withdraw_future_interest', type: 'STRING', value: nil },
          { name: 'withdraw_trigger', type: 'STRING', value: nil },
          { name: 'withdraw_date', type: 'DATE', value: '01/01/2025' },
        ]], job_complete:, page_token:, result:)
      end
    end
  end
end
