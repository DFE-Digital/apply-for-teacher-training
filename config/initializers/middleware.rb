require './app/middlewares/redirect_to_service_gov_uk_middleware'
require './app/middlewares/vendor_api_request_middleware'
require './app/middlewares/service_unavailable_middleware'
require './app/middlewares/request_identity_middleware'

Rails.application.configure do
  config.middleware.insert_before Rack::Sendfile, RedirectToServiceGovUkMiddleware
  config.middleware.use RequestIdentityMiddleware
  config.middleware.use ServiceUnavailableMiddleware
  config.middleware.use VendorAPIRequestMiddleware
  config.middleware.use Grover::Middleware
end
