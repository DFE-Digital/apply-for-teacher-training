module DfE
  module Bigquery
    module TestHelper
      include ::BigqueryStubs

      def stub_bigquery_application_metrics_request(rows: nil)
        bigquery_client = instance_double(Google::Apis::BigqueryV2::BigqueryService)
        allow(DfE::Bigquery).to receive(:client).and_return(bigquery_client)
        allow(bigquery_client).to receive(:query_job).and_return(stubbed_application_metrics(rows:))
      end

      def application_metrics_results(options = {})
        [
          {
            cycle_week: 7,
            first_date_in_week: Date.new(2023, 11, 13),
            last_date_in_week: Date.new(2023, 11, 19),
            nonsubject_filter: '21',
            number_of_candidates_submitted_to_date: 400,
            number_of_candidates_submitted_to_same_date_previous_cycle: 200,
            number_of_candidates_who_did_not_meet_any_offer_conditions_this_cycle_to_date: 30,
            number_of_candidates_who_did_not_meet_any_offer_conditions_this_cycle_to_same_date_previous_cycle: 15,
            number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date: 100,
            number_of_candidates_who_had_all_applications_rejected_this_cycle_to_same_date_previous_cycle: 50,
            number_of_candidates_with_all_accepted_offers_withdrawn_this_cycle_to_date: 200,
            number_of_candidates_with_all_accepted_offers_withdrawn_this_cycle_to_same_date_previous_cycle: 100,
            number_of_candidates_with_deferred_offers_from_this_cycle_to_date: 0,
            number_of_candidates_with_deferred_offers_from_this_cycle_to_same_date_previous_cycle: 0,
            number_of_candidates_with_offers_to_date: 598,
            number_of_candidates_with_offers_to_same_date_previous_cycle: 567,
            number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date: 285,
            number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_same_date_previous_cycle: 213,
            number_of_candidates_accepted_to_date: 20,
            number_of_candidates_accepted_to_same_date_previous_cycle: 10,
          }.merge(options.slice(:attributes)),
        ]
      end

      def stubbed_application_metrics(rows: nil)
        return stub_response(rows:) if rows

        stub_response(rows: [[
          { name: 'cycle_week', type: 'INTEGER', value: '7' },
          { name: 'first_date_in_week', type: 'INTEGER', value: Date.new(2023, 11, 13) },
          { name: 'last_date_in_week', type: 'INTEGER', value: Date.new(2023, 11, 19) },
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
          { name: 'number_of_candidates_with_offers_to_same_date_previous_cycle', type: 'INTEGER', value: '567' },
          { name: 'number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date', type: 'INTEGER', value: '285' },
          { name: 'number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_same_date_previous_cycle', type: 'INTEGER', value: '213' },
          { name: 'number_of_candidates_accepted_to_date', type: 'INTEGER', value: '20' },
          { name: 'number_of_candidates_accepted_to_same_date_previous_cycle', type: 'INTEGER', value: '10' },
        ]])
      end

      def application_metrics_by_provider_results(rows = [])
        return stub_response(rows:) if rows.present?

        stub_response(rows: [[
          { name: 'id', type: 'INTEGER', value: '1337' },
          { name: 'cycle_week', type: 'INTEGER', value: '18' },
          { name: 'recruitment_cycle_year', type: 'INTEGER', value: '2024' },
          { name: 'nonprovider_filter', type: 'INTEGER', value: 'Level' },
          { name: 'nonprovider_filter_category', type: 'INTEGER', value: 'Primary' },
          { name: 'number_of_candidates_submitted_to_date', type: 'INTEGER', value: '100' },
          { name: 'number_of_candidates_submitted_to_same_date_previous_cycle', type: 'INTEGER', value: '200' },
          { name: 'number_of_candidates_submitted_to_date_as_proportion_of_last_cycle', type: 'INTEGER', value: '0.5' },
          { name: 'number_of_candidates_with_offers_to_date', type: 'INTEGER', value: '10' },
          { name: 'number_of_candidates_with_offers_to_same_date_previous_cycle', type: 'INTEGER', value: '5' },
          { name: 'number_of_candidates_with_offers_to_date_as_proportion_of_last_cycle', type: 'INTEGER', value: '2.0' },
          { name: 'offer_rate_to_date', type: 'INTEGER', value: 'nil' },
          { name: 'offer_rate_to_same_date_previous_cycle', type: 'INTEGER', value: 'nil' },
          { name: 'number_of_candidates_accepted_to_date', type: 'INTEGER', value: '1' },
          { name: 'number_of_candidates_accepted_to_same_date_previous_cycle', type: 'INTEGER', value: '10' },
          { name: 'number_of_candidates_accepted_to_date_as_proportion_of_last_cycle', type: 'INTEGER', value: '0.1' },
          { name: 'number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date', type: 'INTEGER', value: '12' },
          { name: 'number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_same_date_previous_cycle', type: 'INTEGER', value: '12' },
          { name: 'number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date_as_proportion_of_last_cycle', type: 'INTEGER', value: '0' },
          { name: 'number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date', type: 'INTEGER', value: '12' },
          { name: 'number_of_candidates_who_had_all_applications_rejected_this_cycle_to_same_date_previous_cycle', type: 'INTEGER', value: '12' },
          { name: 'number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date_as_proportion_of_last_cycle', type: 'INTEGER', value: '0' },
          { name: 'number_of_candidates_who_had_an_inactive_application_this_cycle_to_date', type: 'INTEGER', value: '12' },
          { name: 'number_of_candidates_who_had_an_inactive_application_this_cycle_to_date_as_proportion_of_submitted_candidates', type: 'INTEGER', value: '12' },
        ]])
      end
    end
  end
end
