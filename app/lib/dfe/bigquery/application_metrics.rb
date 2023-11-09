module DfE
  module Bigquery
    class ApplicationMetrics
      attr_accessor :number_of_candidates_submitted_to_date,
                    :number_of_candidates_submitted_to_same_date_previous_cycle,
                    :number_of_candidates_with_offers_to_date,
                    :number_of_candidates_with_offers_to_same_date_previous_cycle,
                    :number_of_candidates_accepted_to_date,
                    :number_of_candidates_accepted_to_same_date_previous_cycle,
                    :number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date,
                    :number_of_candidates_who_had_all_applications_rejected_this_cycle_to_same_date_previous_cycle,
                    :number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date,
                    :number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_same_date_previous_cycle,
                    :number_of_candidates_with_deferred_offers_from_this_cycle_to_date,
                    :number_of_candidates_with_deferred_offers_from_this_cycle_to_same_date_previous_cycle,
                    :number_of_candidates_with_all_accepted_offers_withdrawn_this_cycle_to_date,
                    :number_of_candidates_with_all_accepted_offers_withdrawn_this_cycle_to_same_date_previous_cycle,
                    :number_of_candidates_who_did_not_meet_any_offer_conditions_this_cycle_to_date,
                    :number_of_candidates_who_did_not_meet_any_offer_conditions_this_cycle_to_same_date_previous_cycle,
                    :first_date_in_week,
                    :last_date_in_week,
                    :cycle_week

      def initialize(attributes)
        attributes.each do |key, value|
          send("#{key}=", value) if respond_to?("#{key}=")
        end
      end

      def self.candidate_headline_statistics(cycle_week:)
        result = ::DfE::Bigquery.client.query(
          <<~SQL,
            SELECT *
            FROM dataform.application_metrics
            WHERE recruitment_cycle_year = #{RecruitmentCycle.current_year}
            AND cycle_week = #{cycle_week}
            AND subject_filter_category = "Total excluding Further Education"
            AND nonsubject_filter_category = "Total"
          SQL
        ).first

        new(result)
      end
    end
  end
end
