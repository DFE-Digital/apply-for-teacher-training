defaults api_version: CandidateAPISpecification::CURRENT_VERSION do
  namespace :candidate_api, path: 'candidate-api(/:api_version)', api_version: /v[.0-9]+/, constraints: ValidCandidateApiRoute do
    get '/candidates' => 'candidates#index'
    get '/candidates/:candidate_id' => 'candidates#show'
  end
end
