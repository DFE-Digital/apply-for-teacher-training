require 'rails_helper'

RSpec.describe SupportInterface::ApplicationsFilter do
  let!(:application_choice_with_offer) { create(:application_choice, :with_offer, :previous_year) }
  let!(:application_choice_with_interview) { create(:application_choice, :with_scheduled_interview) }

  def verify_filtered_applications_for_params(expected_applications, params:)
    applications = ApplicationForm.all
    filter = described_class.new(params: params)
    expect(filter.filter_records(applications)).to match_array expected_applications
  end

  describe '#filter_records' do
    it 'supports search by name' do
      expected_form = application_choice_with_offer.application_form

      verify_filtered_applications_for_params(
        [expected_form],
        params: {
          q: application_choice_with_offer.application_form.full_name,
        },
      )
    end

    it 'supports application choice id lookups' do
      expected_form = application_choice_with_offer.application_form

      verify_filtered_applications_for_params(
        [expected_form],
        params: {
          application_choice_id: application_choice_with_offer.id,
        },
      )
    end

    it 'handles non-integer application choice ids' do
      verify_filtered_applications_for_params(
        [],
        params: {
          application_choice_id: "ABC#{application_choice_with_offer.id}",
        },
      )
    end

    it 'can filter by year' do
      expected_form = application_choice_with_offer.application_form

      verify_filtered_applications_for_params(
        [expected_form],
        params: {
          year: [RecruitmentCycle.previous_year],
        },
      )
    end

    it 'can show applications with interviews' do
      expected_form = application_choice_with_interview.application_form

      verify_filtered_applications_for_params(
        [expected_form],
        params: {
          interviews: %w[has_interviews],
        },
      )
    end
  end
end
