namespace :publications, path: '/publications' do
  get '/monthly-statistics/ITT(:year)' => 'monthly_statistics#show', as: :monthly_report_itt
  get '/monthly-statistics(/:month)' => 'monthly_statistics#show', as: :monthly_report
  get '/monthly-statistics/:month/:export_type' => 'monthly_statistics#download', as: :monthly_report_download
  get '/mid-cycle-report' => 'mid_cycle_report#show', as: :mid_cycle_report
end
