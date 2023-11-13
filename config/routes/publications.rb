namespace :publications, path: '/publications' do
  get '/monthly-statistics/temporarily-unavailable', to: 'monthly_statistics#temporarily_unavailable', as: :monthly_statistics_temporarily_unavailable
  get '/monthly-statistics/ITT(:year)' => 'monthly_statistics#show', as: :monthly_report_itt
  constraints(Publications::MonthlyStatisticsRedirectConstraint.new) do
    get '/monthly-statistics(/:month)' => redirect('/publications/monthly-statistics/temporarily-unavailable'), as: :monthly_report_unavailable
    get '/monthly-statistics/:month/:export_type' => redirect('/publications/monthly-statistics/temporarily-unavailable'), as: :monthly_report_download_unavailable
  end
  get '/monthly-statistics(/:month)' => 'monthly_statistics#show', as: :monthly_report
  get '/monthly-statistics/:month/:export_type' => 'monthly_statistics#download', as: :monthly_report_download
  get '/mid-cycle-report' => 'mid_cycle_report#show', as: :mid_cycle_report
end
