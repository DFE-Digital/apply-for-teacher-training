require 'rails_helper'

RSpec.describe ProvidersForRecruitmentPerformanceReportQuery do
  subject(:query) { described_class.call(cycle_week: current_cycle_week.pred, recruitment_cycle_year: current_year) }

  let(:application_choice_offer_from_last_cycle) { create(:application_choice, :awaiting_provider_decision).provider }
  let(:application_this_week) { create(:application_choice, :awaiting_provider_decision).provider }
  let(:application_last_week) { create(:application_choice, :awaiting_provider_decision).provider }
  let(:application_last_week_unsubmitted) { create(:application_choice, :unsubmitted).provider }
  let(:application_with_existing_report) do
    create(:application_choice, :awaiting_provider_decision).provider.tap do |provider|
      Publications::ProviderRecruitmentPerformanceReport.create(
        cycle_week: current_cycle_week,
        recruitment_cycle_year: current_year,
        provider_id: provider.id,
        publication_date: Time.zone.today,
      )
    end
  end

  it 'selects providers only with submitted applications this cycle before the current week', time: mid_cycle do
    TestSuiteTimeMachine.travel_temporarily_to(1.year.ago) do
      application_choice_offer_from_last_cycle
    end
    TestSuiteTimeMachine.travel_temporarily_to(1.week.ago) do
      application_last_week
      application_with_existing_report
      application_last_week_unsubmitted
    end

    application_this_week
    expect(query).to contain_exactly(application_last_week)
  end

  it 'selects distinct providers when a provider has more than one application', time: mid_cycle do
    TestSuiteTimeMachine.travel_temporarily_to(1.week.ago) do
      application_last_week
      create(:application_choice, :awaiting_provider_decision, course_option: application_last_week.course_options.first)
    end

    expect(query).to contain_exactly(application_last_week)
  end
end
