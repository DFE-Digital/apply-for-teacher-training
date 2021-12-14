require 'rails_helper'

RSpec.describe 'GET /data-api/tad-data-exports/applications-by-demographic-domicile-and-degree-grade/latest', type: :request, sidekiq: true do
  include DataAPISpecHelper

  it_behaves_like 'a TAD API endpoint', '/latest'

  it 'returns the latest tad age and hesa export' do
    first_application_form = create(
      :completed_application_form,
      equality_and_diversity: {
        'sex' => 'male',
        'hesa_sex' => '1',
        'disabilities' => ['Learning difficulty', 'Social or communication impairment', 'Blind'],
        'ethnic_group' => 'Another ethnic group',
        'hesa_ethnicity' => '50',
        'ethnic_background' => 'Arab',
        'hesa_disabilities' => %w[51 53 58],
      },
    )
    create(:application_qualification, level: 'degree', grade: 'Upper second-class honours (2:1)', application_form: first_application_form)
    create(:application_choice, :with_recruited, application_form: first_application_form)

    data_export = DataExport.create!(
      name: 'Weekly export of the TAD applications by demographic, domicile and degree class',
      export_type: :applications_by_demographic_domicile_and_degree_class,
    )

    DataExporter.perform_async(SupportInterface::ApplicationsByDemographicDomicileAndDegreeClassExport, data_export.id)

    get_api_request '/data-api/applications-by-demographic-domicile-and-degree-class/latest', token: tad_api_token

    expect(response).to have_http_status(:success)
    expect(response.body).to start_with('age_group,sex,ethnicity,disability,degree_class,domicile,pending_conditions,recruited,total')
  end
end
