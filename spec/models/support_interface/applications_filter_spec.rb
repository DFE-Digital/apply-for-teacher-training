require 'rails_helper'

RSpec.describe SupportInterface::ApplicationsFilter do
  let(:application_choice_with_offer) do
    primary = create(:subject, name: 'Primary', code: 'F0')
    course = create(:course, subjects: [primary])
    course_option = create(:course_option, course: course)

    create(:application_choice, :offered, :previous_year, course_option: course_option)
  end

  let(:application_form_with_opt_out_status) do
    candidate = create(:candidate)
    application_form = create(:completed_application_form, candidate:)

    create(:candidate_preference, pool_status: 'opt_out', status: 'published', candidate:)
    create(:application_choice, application_form:)

    application_form
  end

  let!(:application_choice_with_interview) { create(:application_choice, :interviewing, application_form: create(:completed_application_form, first_nationality: 'British')) }
  let!(:application_choice_recruited) { create(:application_choice, :recruited) }
  let!(:international_application) { create(:completed_application_form, first_nationality: 'American') }

  def verify_filtered_applications_for_params(expected_applications, params:)
    applications = ApplicationForm.all
    filter = described_class.new(params:)
    expect(filter.filter_records(applications).last).to match_array(expected_applications)
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

    it 'supports search by name with superfluous spaces' do
      expected_form = application_choice_with_offer.application_form

      verify_filtered_applications_for_params(
        [expected_form],
        params: {
          q: " #{application_choice_with_offer.application_form.full_name} ",
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
                                  status: :rejected,
                                  course_option:,
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
          year: [previous_year],
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

    it 'can filter by subject' do
      expected_form = application_choice_with_offer.application_form

      verify_filtered_applications_for_params(
        [expected_form],
        params: {
          subject: %w[Primary],
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

    it 'can filter by home nationality' do
      verify_filtered_applications_for_params(
        [application_choice_recruited.application_form, application_choice_with_offer.application_form, application_choice_with_interview.application_form],
        params: {
          nationality: ['false'],
        },
      )
    end

    it 'can filter by international nationality' do
      verify_filtered_applications_for_params(
        [international_application],
        params: {
          nationality: ['true'],
        },
      )
    end

    it 'can filter by Find a Candidate opt-in status' do
      verify_filtered_applications_for_params(
        [application_form_with_opt_out_status],
        params: {
          opt_in_status: ['opt_out'],
        },
      )
    end
  end
end
