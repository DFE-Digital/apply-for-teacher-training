options = {
  name: :dfe,
  callback_path: '/auth/dfe/callback',
}

class OmniAuth::Strategies::Dfe < OmniAuth::Strategies::OpenIDConnect; end

Rails.application.config.middleware.use OmniAuth::Strategies::Dfe, options

