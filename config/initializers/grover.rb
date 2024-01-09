Grover.configure do |config|
  config.options = {
    format: 'A4',
    margin: {
      top: '1.5cm',
      bottom: '1.5cm',
      left: '1.5cm',
      right: '1.5cm',
    },
    emulate_media: 'print',
  }
  config.ignore_path = /^(?!\/provider\/applications\/\d+)/
end
