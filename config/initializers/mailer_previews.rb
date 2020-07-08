ActiveSupport.on_load(:action_controller, run_once: true) do
  Rails::MailersController.prepend(ApplyMailersController)
end
