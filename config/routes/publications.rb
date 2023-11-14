namespace :publications, path: '/publications' do
  get '/monthly-statistics/temporarily-unavailable', to: 'monthly_statistics#temporarily_unavailable', as: :monthly_statistics_temporarily_unavailable
  constraints(Publications::MonthlyStatisticsRedirectConstraint.new) do
    constraints(->(req) { (2024..).include?(req.params[:year].to_i) }) do
      get '/monthly-statistics/ITT(:year)' => redirect('/publications/monthly-statistics/temporarily-unavailable'), as: :monthly_report_itt_v2_redirect
    end
  end

  constraints(->(req) { (2024..).include?(req.params[:year].to_i) }) do
    get '/monthly-statistics/ITT(:year)' => 'v2/monthly_statistics#show', as: :monthly_report_itt_v2
  end

  get '/monthly-statistics/ITT(:year)' => 'monthly_statistics#show', as: :monthly_report_itt

  constraints(Publications::MonthlyStatisticsRedirectConstraint.new) do
    get '/monthly-statistics(/:month)' => redirect('/publications/monthly-statistics/temporarily-unavailable'), as: :monthly_report_unavailable
    get '/monthly-statistics/:month/:export_type' => redirect('/publications/monthly-statistics/temporarily-unavailable'), as: :monthly_report_download_unavailable
  end

  get '/monthly-statistics(/:month)' => 'monthly_statistics#show', as: :monthly_report
  get '/monthly-statistics/:month/:export_type' => 'monthly_statistics#download', as: :monthly_report_download
  get '/mid-cycle-report' => 'mid_cycle_report#show', as: :mid_cycle_report
end
