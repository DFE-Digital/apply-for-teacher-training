class IntegrationsRoutes < RouteExtension
  def routes
    post '/notify/callback' => 'notify#callback'
  end
end
