module DfE
  module Bigquery
    module TestHelper
      include ::BigqueryStubs

      def stub_bigquery_application_metrics_request(rows: nil, job_complete: true, page_token: nil)
        bigquery_client = instance_double(Google::Apis::BigqueryV2::BigqueryService)
        allow(DfE::Bigquery).to receive(:client).and_return(bigquery_client)
        allow(bigquery_client).to receive(:query_job).and_return(stubbed_bigquery_application_metrics_response(rows:, job_complete:, page_token:))
      end

      def stub_bigquery_application_metrics_by_provider_request(rows: nil, job_complete: true, page_token: nil)
        bigquery_client = instance_double(Google::Apis::BigqueryV2::BigqueryService)
        allow(DfE::Bigquery).to receive(:client).and_return(bigquery_client)
        allow(bigquery_client).to receive(:query_job).and_return(stubbed_bigquery_application_metrics_by_provider_response(rows:, job_complete:, page_token:))
      end

      def stubbed_bigquery_application_metrics_response(rows: nil, job_complete: nil, page_token: nil)
        return stub_response(rows:, job_complete:, page_token:) if rows

        stub_response(rows: [[
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
        ]], job_complete:, page_token:)
      end

      def stubbed_bigquery_application_metrics_by_provider_response(rows: nil, job_complete: nil, page_token: nil)
        return stub_response(rows:) if rows

        stub_response(rows: [[
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
        ]], job_complete:, page_token:)
      end
    end
  end
end
