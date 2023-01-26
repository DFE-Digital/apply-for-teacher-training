namespace :data_api, path: '/data-api' do
  get '/tad-data-exports/latest' => 'tad_data_exports#latest'
  get '/applications-by-subject-route-and-degree-grade/latest' => 'tad_data_exports#applications_by_subject_route_and_degree_grade'
  get '/applications-by-subject-domicile-and-nationality/latest' => 'tad_data_exports#subject_domicile_nationality_latest'
  get '/applications-by-demographic-domicile-and-degree-class/latest' => 'tad_data_exports#applications_by_demographic_domicile_and_degree_class'
  get '/ministerial-report/candidates/latest' => 'tad_data_exports#candidates'
  get '/ministerial-report/applications/latest' => 'tad_data_exports#applications'
  get '/tad-data-exports' => 'tad_data_exports#index'
  get '/tad-data-exports/:id' => 'tad_data_exports#show', as: :tad_export
end
