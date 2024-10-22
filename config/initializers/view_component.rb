require './app/lib/hosting_environment'

Rails.application.configure do
  show_previews = HostingEnvironment.test_environment?

  config.view_component.preview_paths = [Rails.root.join('spec/components/previews')]
  config.view_component.show_previews = show_previews
end
