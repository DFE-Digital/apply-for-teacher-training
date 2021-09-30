require 'rails_helper'

RSpec.describe SupportInterface::ApplicationsFilter do
  let!(:application_choice_with_offer) do
    create(:application_choice, :with_completed_application_form, :with_offer, :previous_year)
  end
  let!(:application_choice_with_interview) { create(:application_choice, :with_scheduled_interview) }

  def verify_filtered_applications_for_params(expected_applications, params:, provider_page: false)
    applications = ApplicationForm.all
    filter = described_class.new(params: params, provider_page: provider_page)
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

    it 'can filter by status' do
      expected_form = application_choice_with_offer.application_form

      verify_filtered_applications_for_params(
        [expected_form],
        params: {
          status: %w[offer],
        },
      )
    end

    context 'on the candidates page' do
      it 'cannot filter by training provider' do
        expected_form1 = application_choice_with_offer.application_form
        expected_form2 = application_choice_with_interview.application_form

        verify_filtered_applications_for_params(
          [expected_form1, expected_form2],
          params: {
            training_provider: [application_choice_with_offer.provider.id],
          },
        )
      end

      it 'cannot filter by accredited provider' do
        expected_form1 = application_choice_with_offer.application_form
        expected_form2 = application_choice_with_interview.application_form

        verify_filtered_applications_for_params(
          [expected_form1, expected_form2],
          params: {
            accredited_provider: [application_choice_with_offer.provider.id],
          },
        )
      end
    end

    context 'on the providers page' do
      it 'can filter by training provider' do
        expected_form = application_choice_with_offer.application_form

        verify_filtered_applications_for_params(
          [expected_form],
          params: {
            training_provider: [application_choice_with_offer.provider.id],
          },
          provider_page: true,
        )
      end

      it 'can filter by accredited provider' do
        course = create(:course, :with_accredited_provider)
        course_option = create(:course_option, course: course)
        application_choice = create(:application_choice, course_option: course_option)

        expected_form = application_choice.application_form

        verify_filtered_applications_for_params(
          [expected_form],
          params: {
            accredited_provider: [course.accredited_provider.id],
          },
          provider_page: true,
        )
      end
    end
  end
end
