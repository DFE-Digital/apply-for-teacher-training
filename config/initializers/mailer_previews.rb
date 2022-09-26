ActiveSupport.on_load(:action_controller, run_once: true) do
  require 'apply_mailers_controller'
  Rails::MailersController.prepend(ApplyMailersController)
end
