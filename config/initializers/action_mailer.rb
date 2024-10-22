require './app/lib/hosting_environment'

Rails.application.configure do
  show_previews = HostingEnvironment.test_environment?

  config.action_mailer.preview_paths = [Rails.root.join('spec/mailers/previews')]
  config.action_mailer.show_previews = show_previews
  config.action_mailer.deliver_later_queue_name = :mailers
end
