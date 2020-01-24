class ApiDocsRoutes < RouteExtension
  def routes
    get '/' => 'pages#home', as: :home
    get '/usage-scenarios' => 'pages#usage', as: :usage
    get '/reference' => 'reference#reference', as: :reference
    get '/release-notes' => 'pages#release_notes', as: :release_notes
    get '/alpha-release-notes' => 'pages#alpha_release_notes'
    get '/help' => 'pages#help', as: :help
    get '/spec.yml' => 'openapi#spec', as: :spec
  end
end
