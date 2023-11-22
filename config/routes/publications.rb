namespace :publications, path: '/publications' do
  get '/monthly-statistics/temporarily-unavailable', to: 'monthly_statistics#temporarily_unavailable', as: :monthly_statistics_temporarily_unavailable

  get '/monthly-statistics' => 'monthly_statistics#latest', as: :monthly_report
  get '/monthly-statistics/ITT(:year)' => 'monthly_statistics#by_year', as: :monthly_report_itt
  get '/monthly-statistics/:month' => 'monthly_statistics#by_month', as: :monthly_report_at
  get '/monthly-statistics/:month/:export_type' => 'monthly_statistics#download', as: :monthly_report_download

  get '/mid-cycle-report' => 'mid_cycle_report#show', as: :mid_cycle_report
end
