Rails.application.config.public_file_server.headers = {
  'Cache-Control' => 'max-age=31536000, public, immutable',
}
