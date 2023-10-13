Rails.application.routes.draw do
  if HostingEnvironment.sandbox_mode?
    root to: 'content#sandbox'
  else
    root to: redirect('/candidate/account')
  end

  # User interfaces
  draw 'candidate'
  draw 'provider'
  draw 'publications'
  draw 'referee'
  draw 'support'

  # APIs (with docs)
  draw 'api/candidate'
  draw 'api/data'
  draw 'api/docs'
  draw 'api/register'
  draw 'api/vendor'

  get '/auth/dfe/callback' => 'dfe_sign_in#callback'
  post '/auth/developer/callback' => 'dfe_sign_in#bypass_callback'
  get '/auth/dfe/sign-out' => 'dfe_sign_in#redirect_after_dsi_signout'

  direct :find do
    if HostingEnvironment.sandbox_mode?
      I18n.t('find_postgraduate_teacher_training.sandbox_url')
    elsif HostingEnvironment.qa?
      I18n.t('find_postgraduate_teacher_training.qa_url')
    else
      I18n.t('find_postgraduate_teacher_training.production_url')
    end
  end

  namespace :integrations, path: '/integrations' do
    post '/notify/callback' => 'notify#callback'
    get '/feature-flags' => 'feature_flags#index'
    get '/performance-dashboard' => redirect('support/performance/service')
  end

  get '/check', to: 'healthcheck#show'
  get '/check/version', to: 'healthcheck#version'

  mount Yabeda::Prometheus::Exporter => '/metrics'

  scope via: :all do
    get '/404', to: 'errors#not_found'
    get '/406', to: 'errors#not_acceptable'
    get '/422', to: 'errors#unprocessable_entity'
    get '/500', to: 'errors#internal_server_error'
  end
end
