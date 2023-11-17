module DfE
  module Bigquery
    module TestHelper
      def stub_bigquery_application_metrics_request
        stub_bigquery_client
        allow(bigquery_client).to receive(:query).and_return(application_metrics_results)
      end

      def stub_bigquery_client
        DfE::Bigquery.instance_variable_set(:@client, nil)
        allow(DfE::Bigquery).to receive(:client).and_return(bigquery_client)
      end

      def bigquery_client
        @bigquery_client ||= instance_double(Google::Cloud::Bigquery::Project)
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
    end
  end
end
