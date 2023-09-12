require 'rails_helper'

RSpec.describe 'GET /data-api/tad-data-exports/applications-by-demographic-domicile-and-degree-grade/latest', :sidekiq do
  include DataAPISpecHelper

  let(:first_row) do
    response.body.split("\n")[1]
  end
  let(:data_export) do
    DataExport.create!(
      name: 'Weekly export of the TAD applications by demographic, domicile and degree class',
      export_type: :applications_by_demographic_domicile_and_degree_class,
    )
  end
  let(:first_application_form) do
    create(
      :completed_application_form,
      equality_and_diversity: {
        'sex' => 'male',
        'hesa_sex' => '11',
        'disabilities' => ['Learning difficulty', 'Social or communication impairment', 'Blind'],
        'ethnic_group' => 'Another ethnic group',
        'hesa_ethnicity' => '50',
        'ethnic_background' => 'Arab',
        'hesa_disabilities' => %w[51 53 58],
      },
    )
  end

  it_behaves_like 'a TAD API endpoint', '/latest'

  it 'returns the latest tad age and hesa export' do
    create(:application_qualification, level: 'degree', grade: 'Upper second-class honours (2:1)', application_form: first_application_form)
    create(:application_choice, :recruited, application_form: first_application_form)

    DataExporter.perform_async(SupportInterface::ApplicationsByDemographicDomicileAndDegreeClassExport.to_s, data_export.id)

    get_api_request '/data-api/applications-by-demographic-domicile-and-degree-class/latest', token: tad_api_token

    expect(response).to have_http_status(:success)
    expect(response.body).to start_with('age_group,sex,ethnicity,disability,degree_class,domicile,pending_conditions,recruited,total')
    expect(first_row).to include('Upper second-class honours (2:1)')
  end

  %w[intersex other].each do |option|
    context 'when sending old and new sex values' do
      it 'returns the latest tad age and hesa export' do
        first_application_form.equality_and_diversity.merge!({ 'sex' => option.to_s })
        first_application_form.save
        create(:application_qualification, level: 'degree', grade: 'First-class honours', application_form: first_application_form)
        create(:application_choice, :recruited, application_form: first_application_form)

        DataExporter.perform_async(SupportInterface::ApplicationsByDemographicDomicileAndDegreeClassExport.to_s, data_export.id)

        get_api_request '/data-api/applications-by-demographic-domicile-and-degree-class/latest', token: tad_api_token

        expect(response).to have_http_status(:success)
        expect(response.body).to start_with('age_group,sex,ethnicity,disability,degree_class,domicile,pending_conditions,recruited,total')
        expect(first_row).to include('Other')
      end
    end
  end

  context 'when sending the new formatted degree grade' do
    before do
      create(:application_qualification, level: 'degree', grade: 'First-class honours', application_form: first_application_form)
      create(:application_choice, :recruited, application_form: first_application_form)

      DataExporter.perform_async(SupportInterface::ApplicationsByDemographicDomicileAndDegreeClassExport.to_s, data_export.id)

      get_api_request '/data-api/applications-by-demographic-domicile-and-degree-class/latest', token: tad_api_token
    end

    it 'returns the latest tad age and hesa export' do
      expect(response).to have_http_status(:success)
      expect(response.body).to start_with('age_group,sex,ethnicity,disability,degree_class,domicile,pending_conditions,recruited,total')
      expect(first_row).to include('First class honours')
    end
  end
end
