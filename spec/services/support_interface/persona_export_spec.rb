require 'rails_helper'

RSpec.describe SupportInterface::PersonaExport do
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
      'Candidate id' => application_form.candidate.id,
      'Support reference' => application_form.support_reference,
      'Age' => 20,
      'Candidate postcode' => application_form.postcode,
      'Provider postcode' => application_choice.provider.postcode,
      'Site postcode' => application_choice.site.postcode,
      'Site region' => application_choice.site.region,
      'Provider type' => 'lead_school',
      'Accrediting provider type' => 'scitt',
      'Program type' => 'scitt_programme',
      'Degree completed' => '2020',
      'Degree type' => 'Bachelor of Theology',
      'Distance from site to candidate' => '2.2',
      'Average distance from all sites to candidate' => '2.2',
      'Rejection reason' => nil,
      'Structured rejection reasons' => "Something you did\nHonesty and professionalism",
      'Application status' => 'Ended without success',
      'Course code' => application_choice.course.code,
      'Provider code' => application_choice.provider.code,
      'Nationality' => 'GB',
      'Rejected by default at' => application_choice.reject_by_default_at,
      'Link to application' => "https://www.apply-for-teacher-training.service.gov.uk/support/applications/#{application_form.id}",
    }
  end
end
