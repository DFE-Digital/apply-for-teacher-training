Rails.application.configure do
  config.i18n.exception_handler = proc { |exception| raise exception.to_exception }
  config.i18n.raise_on_missing_translations = true
  config.i18n.load_path += Dir[Rails.root.join("config/locales/**/*.{rb,yml}")]
end
