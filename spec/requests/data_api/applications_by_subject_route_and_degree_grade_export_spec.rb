require 'rails_helper'

RSpec.describe 'GET /data-api/applications-by-subject-route-and-degree-grade/latest', :sidekiq do
  include DataAPISpecHelper

  it_behaves_like 'a TAD API endpoint', '/latest'

  it 'returns the latest applications export grouped by subject, route and degree grade' do
    drama = create(:subject, code: '13')
    first_application_form = create(:completed_application_form)
    create(:application_qualification, level: 'degree', grade: 'Upper second-class honours (2:1)', application_form: first_application_form)
    scitt_provider = create(:provider, provider_type: 'scitt')
    first_course = create(:course, provider: scitt_provider, subjects: [drama])
    first_course_option = create(:course_option, course: first_course)

    create(:application_choice, :declined, course_option: first_course_option, application_form: first_application_form)

    data_export = DataExport.create!(
      name: 'Weekly export of the applications export grouped by subject, route and degree grade',
      export_type: :applications_by_subject_route_and_degree_grade,
    )
    DataExporter.perform_async(SupportInterface::ApplicationsBySubjectRouteAndDegreeGradeExport.to_s, data_export.id)

    get_api_request '/data-api/applications-by-subject-route-and-degree-grade/latest', token: tad_api_token

    expect(response).to have_http_status(:success)
    expect(response.body).to start_with('subject,route,grade_hesa_code,applications,offers_received,number_of_acceptances,number_of_declined_applications,number_of_rejected_applications,number_of_withdrawn_applications')
  end
end
