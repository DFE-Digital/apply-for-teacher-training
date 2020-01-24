class VendorApiRoutes < RouteExtension
  def routes
    get '/applications' => 'applications#index'
    get '/applications/:application_id' => 'applications#show'

    post '/applications/:application_id/offer' => 'decisions#make_offer'
    post '/applications/:application_id/confirm-conditions-met' => 'decisions#confirm_conditions_met'
    post '/applications/:application_id/conditions-not-met' => 'decisions#conditions_not_met'
    post '/applications/:application_id/reject' => 'decisions#reject'
    post '/applications/:application_id/confirm-enrolment' => 'decisions#confirm_enrolment'

    post '/test-data/regenerate' => 'test_data#regenerate'

    get '/ping', to: 'ping#ping'
  end
end
