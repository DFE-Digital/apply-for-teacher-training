namespace :api_docs, path: nil do
  scope module: :vendor_api_docs, path: '/api-docs' do
    get '/' => 'pages#home', as: :home
    get '/usage-scenarios' => 'pages#usage', as: :usage

    get '/release-notes' => 'pages#release_notes', as: :release_notes
    get '/alpha-release-notes' => 'pages#alpha_release_notes'
    get '/lifecycle' => 'pages#lifecycle'
    get '/help' => 'pages#help', as: :help

    get '/reference' => 'reference#reference', as: :reference
    get '/draft' => 'reference#draft', as: :draft
    get '/:api_version/reference' => 'reference#reference', constraints: { api_version: /v[.0-9]+/ }, as: :versioned_reference

    get '/spec.yml' => 'openapi#spec_current', as: :spec
    get '/spec-draft.yml' => 'openapi#spec_draft', as: :spec_draft
    get '/spec-1.0.yml' => 'openapi#spec_1_0', as: :spec_1_0
    get '/spec-1.1.yml' => 'openapi#spec_1_1', as: :spec_1_1
    get '/spec-1.2.yml' => 'openapi#spec_1_2', as: :spec_1_2
    get '/spec-1.3.yml' => 'openapi#spec_1_3', as: :spec_1_3
    get '/spec-1.4.yml' => 'openapi#spec_1_4', as: :spec_1_4
    get '/spec-1.5.yml' => 'openapi#spec_1_5', as: :spec_1_5
    get '/spec-1.6.yml' => 'openapi#spec_1_6', as: :spec_1_6
  end

  namespace :data_api_docs, path: '/data-api' do
    get '/' => 'reference#reference', as: :home
    get '/spec.yml' => 'open_api#spec', as: :spec
  end

  namespace :register_api_docs, path: '/register-api' do
    get '/' => 'reference#reference', as: :home
    get '/spec.yml' => 'open_api#spec', as: :spec
    get '/release-notes' => 'pages#release_notes', as: :release_notes
  end

  defaults api_version: CandidateAPISpecification::CURRENT_VERSION do
    namespace :candidate_api_docs, path: '/candidate-api(/:api_version)', api_version: /v[.0-9]+/, constraints: ValidCandidateApiRoute do
      get '/' => 'reference#reference', as: :home
      get '/spec.yml' => 'open_api#spec', as: :spec
    end
  end
end
