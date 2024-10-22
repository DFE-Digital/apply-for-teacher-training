require "grover"

Grover.configure do |config|
  config.options = {
    format: 'A4',
    margin: {
      top: '1.5cm',
      bottom: '1.5cm',
      left: '1.5cm',
      right: '1.5cm',
    },
    print_background: true,
    scale: 0.8,
    launch_args: ['--disable-gpu', '--disable-dev-shm-usage', '--no-sandbox', '--disable-setuid-sandbox'],
  }
  config.ignore_path = /^(?!\/provider\/applications\/\d+)/
end
