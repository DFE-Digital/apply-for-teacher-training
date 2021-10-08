require 'rails_helper'

RSpec.describe SupportInterface::ApplicationsFilter do
  let!(:application_choice_with_offer) do
    create(:application_choice, :with_completed_application_form, :with_offer, :previous_year)
  end
  let!(:application_choice_with_interview) { create(:application_choice, :with_scheduled_interview) }
  let!(:application_choice_recruited) { create(:application_choice, :with_recruited) }

  def verify_filtered_applications_for_params(expected_applications, params:)
    applications = ApplicationForm.all
    filter = described_class.new(params: params)
    expect(filter.filter_records(applications)).to match_array(expected_applications)
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

    it 'returns an application form with multiple application choices once' do
      course_option = create(:course_option, course: application_choice_with_offer.course)
      application_choice = create(:application_choice,
                                  application_form: application_choice_with_offer.application_form,
                                  course_option: course_option,
                                  provider_ids: application_choice_with_offer.provider_ids)

      verify_filtered_applications_for_params(
        [application_choice.application_form],
        params: {
          provider_id: application_choice_with_offer.provider_ids.first,
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

    it 'can filter by status' do
      expected_form = application_choice_with_offer.application_form

      verify_filtered_applications_for_params(
        [expected_form],
        params: {
          status: %w[offer],
        },
      )
    end

    it 'can filter by the recruited status' do
      expected_form = application_choice_recruited.application_form

      verify_filtered_applications_for_params(
        [expected_form],
        params: {
          status: %w[recruited],
        },
      )
    end
  end
end
