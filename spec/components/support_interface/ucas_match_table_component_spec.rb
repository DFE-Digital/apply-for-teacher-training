require 'rails_helper'

RSpec.describe SupportInterface::UCASMatchTableComponent do
  let(:candidate) { create(:candidate) }
  let(:course) { create(:course) }
  let(:course_option) { create(:course_option, course: course) }
  let(:application_choice) { create(:application_choice, :with_offer, course_option: course_option) }
  let(:application_form) { create(:application_form, candidate: candidate, application_choices: [application_choice]) }
  let(:ucas_match_for_apply_application) { create(:ucas_match, scheme: 'D', application_form: application_form) }
  let(:ucas_match_for_ucas_application) { create(:ucas_match, scheme: 'U', ucas_status: :rejected, application_form: application_form) }
  let(:ucas_match) { create(:ucas_match, scheme: 'B', ucas_status: :rejected, application_form: application_form) }
  let(:ucas_match_course_only_on_ucas) do
    create(:ucas_match,
           matching_data: [{
             'Scheme' => 'U',
             'Course code' => '123',
             'Course name' => 'Not on Apply',
             'Provider code' => course.provider.code.to_s,
             'Apply candidate ID' => candidate.id.to_s,
             'Withdrawns' => '1',
           }])
  end
  let(:ucas_match_for_welsh_provider) do
    create(:ucas_match,
           matching_data: [{
             'Scheme' => 'U',
             'Course code' => '',
             'Course name' => '',
             'Provider code' => 'T80',
             'Apply candidate ID' => candidate.id.to_s,
           }])
  end

  it 'renders course choice details for a course on Apply' do
    result = render_inline(described_class.new(ucas_match))

    expect(result.css('td')[0].text).to include(course.code)
    expect(result.css('td')[1].text).to include("#{course.name} – #{course.provider.name}")
  end

  it 'renders course provider contact details for a course on Apply' do
    provider_user = create(:provider_user, :with_manage_users, providers: [course.provider])
    result = render_inline(described_class.new(ucas_match))

    expect(result.css('td')[1].text).to include('Contact details')
    expect(result.css('td')[1].text).to include(provider_user.full_name)
    expect(result.css('td')[1].text).to include(provider_user.email_address)
  end

  it 'renders course choice details for a course not on Apply' do
    result = render_inline(described_class.new(ucas_match_course_only_on_ucas))

    expect(result.css('td')[0].text).to include('123')
    expect(result.css('td')[1].text).to include("Not on Apply – #{course.provider.name}")
  end

  it 'renders course choice details for a course with missing data and provider' do
    result = render_inline(described_class.new(ucas_match_for_welsh_provider))

    expect(result.css('td')[0].text).to include('Missing course code')
    expect(result.css('td')[1].text).to include('Missing course name – Provider not on Apply')
  end

  context 'when application is in both Apply and UCAS' do
    it 'renders correct statuses for both' do
      result = render_inline(described_class.new(ucas_match))

      expect(result.css('td')[2].text).to include('Rejected')
      expect(result.css('td')[3].text).to include('Offer made')
    end

    it 'renders correct summary' do
      result = render_inline(described_class.new(ucas_match))

      expect(result.text).to include('This applicant has applied to the same course on both services.')
    end
  end

  context 'when application is only on Apply' do
    it 'renders correct statuses' do
      result = render_inline(described_class.new(ucas_match_for_apply_application))

      expect(result.css('td')[2].text).to include('N/A')
      expect(result.css('td')[3].text).to include('Offer made')
    end

    it 'renders correct summary' do
      result = render_inline(described_class.new(ucas_match_for_apply_application))

      expect(result.text).to include('This applicant has applied on both services but not for the same course.')
    end
  end

  context 'when application is only on UCAS' do
    it 'renders correct statuses for a course on Apply' do
      result = render_inline(described_class.new(ucas_match_for_ucas_application))

      expect(result.css('td')[2].text).to include('Rejected')
      expect(result.css('td')[3].text).to include('N/A')
    end

    it 'renders correct statuses for a course which is not on Apply' do
      result = render_inline(described_class.new(ucas_match_course_only_on_ucas))

      expect(result.css('td')[2].text).to include('Withdrawn')
      expect(result.css('td')[3].text).to include('N/A')
    end

    it 'renders correct summary' do
      result = render_inline(described_class.new(ucas_match_for_ucas_application))

      expect(result.text).to include('This applicant has applied on both services but not for the same course.')
    end
  end
end
