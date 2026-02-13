FactoryBot.define do
  factory :regional_edi_report, class: '::Publications::RegionalEdiReport' do
    recruitment_cycle_year { 2026 }
    cycle_week { 16 }
    generation_date { Time.zone.local(recruitment_cycle_year, 6, 1) }
    publication_date { Time.zone.local(recruitment_cycle_year, 6, 1) }
    region { :london }
    category { :sex }
    statistics do
      [{ 'nonregion_filter' => 'Prefer not to say',
         'nonregion_filter_category' => 'Sex',
         'cycle_week' => 16,
         'recruitment_cycle_year' => 2026,
         'region_filter' => 'London',
         'number_of_candidates_submitted_to_date' => 101,
         'number_of_candidates_submitted_to_same_date_previous_cycle' => 68,
         'number_of_candidates_submitted_to_date_as_proportion_of_last_cycle' => 1.485294117647059,
         'number_of_candidates_with_offers_to_date' => 4,
         'number_of_candidates_with_offers_to_same_date_previous_cycle' => 4,
         'number_of_candidates_with_offers_to_date_as_proportion_of_last_cycle' => 1.0,
         'offer_rate_to_date' => 0.0396039603960396,
         'offer_rate_to_same_date_previous_cycle' => 0.05882352941176471,
         'number_of_candidates_accepted_to_date' => 4,
         'number_of_candidates_accepted_to_same_date_previous_cycle' => 3,
         'number_of_candidates_accepted_to_date_as_proportion_of_last_cycle' => 1.333333333333333,
         'number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date' => 0,
         'number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_same_date_previous_cycle' => 0,
         'number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date_as_proportion_of_last_cycle' => nil,
         'number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date' => 10,
         'number_of_candidates_who_had_all_applications_rejected_this_cycle_to_same_date_previous_cycle' => 27,
         'number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date_as_proportion_of_last_cycle' => 0.3703703703703703,
         'number_of_candidates_who_had_an_inactive_application_this_cycle_to_date' => 40,
         'number_of_candidates_who_had_an_inactive_application_this_cycle_to_date_as_proportion_of_submitted_candidates' => 0.3960396039603961,
         'number_of_candidates_who_had_an_inactive_application_last_cycle_to_date_as_proportion_of_submitted_candidates_last_cycle' => 0.1911764705882353 }]
    end
  end
end
