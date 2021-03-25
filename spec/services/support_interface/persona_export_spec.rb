require 'rails_helper'

RSpec.describe SupportInterface::PersonaExport do
  describe 'documentation' do
    before { create(:application_choice, application_form: create(:application_form)) }

    it_behaves_like 'a data export'
  end

  describe '#data_for_export' do
    around do |example|
      Timecop.freeze(Date.new(2020, 1, 2)) do
        example.run
      end
    end

    it 'returns a hash of location and application choice related data' do
      application_form = create(
        :application_form,
        date_of_birth: Date.new(2000, 1, 1),
        latitude: 51.5973506,
        longitude: -1.2967454,
        first_nationality: 'British',
      )
      provider = create(:provider, provider_type: 'lead_school')
      accredited_provider = create(:provider, provider_type: 'scitt')
      course = create(:course, provider: provider, accredited_provider: accredited_provider, program_type: 'scitt_programme')
      site = create(:site, latitude: 51.6097184, longitude: -1.2482939, provider: provider)
      course_option = create(:course_option, course: course, site: site)
      create(:degree_qualification, award_year: '2020', application_form: application_form, qualification_type: 'Bachelor of Theology')
      create(:degree_qualification, award_year: '2018', application_form: application_form)
      application_choice = create(
        :application_choice,
        :with_structured_rejection_reasons,
        structured_rejection_reasons: {
          course_full_y_n: 'No',
          candidate_behaviour_y_n: 'Yes',
          candidate_behaviour_other: 'Persistent scratching',
          honesty_and_professionalism_y_n: 'Yes',
          honesty_and_professionalism_concerns: %w[references],
        },
        course_option: course_option,
        application_form: application_form,
      )

      expect(described_class.new.data_for_export).to eq([expected_hash(application_choice)])
    end
  end

private

  def expected_hash(application_choice)
    application_form = application_choice.application_form

    {
      candidate_id: application_form.candidate.id,
      support_reference: application_form.support_reference,
      age: 20,
      candidate_postcode: application_form.postcode,
      provider_postcode: application_choice.provider.postcode,
      site_postcode: application_choice.site.postcode,
      site_region: application_choice.site.region,
      provider_type: 'lead_school',
      accrediting_provider_type: 'scitt',
      program_type: 'scitt_programme',
      degree_award_year: '2020',
      degree_type: 'Bachelor of Theology',
      distance_from_site_to_candidate: '2.2',
      average_distance_from_all_sites: '2.2',
      rejection_reason: nil,
      structured_rejection_reasons: 'Something you did, Honesty and professionalism',
      application_state: 'Ended without success',
      course_code: application_choice.course.code,
      provider_code: application_choice.provider.code,
      nationality: 'GB',
      rejected_by_default_at: application_choice.reject_by_default_at,
      link_to_application: "https://www.apply-for-teacher-training.service.gov.uk/support/applications/#{application_form.id}",
    }
  end
end
