uri = URI(HostingEnvironment.application_url)
Rails.application.routes.default_url_options[:host] = uri.host
Rails.application.routes.default_url_options[:port] = uri.port
Rails.application.routes.default_url_options[:protocol] = uri.scheme
