Rails.application.configure do
  config.action_dispatch.default_headers = {
    "Feature-Policy" => "accelerometer 'none'; ambient-light-sensor: 'none', autoplay: 'none', battery: 'none', camera 'none'; display-capture: 'none', document-domain: 'none', fullscreen: 'none', geolocation 'none'; gyroscope 'none'; magnetometer 'none'; microphone 'none'; midi: 'none', payment 'none'; publickey-credentials-get: 'none', usb 'none', wake-lock: 'none', screen-wake-lock: 'none', web-share: 'none'",
    'Cache-Control' => 'no-store, no-cache',
  }
end
