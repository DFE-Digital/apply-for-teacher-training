ActiveSupport.on_load(:action_controller, run_once: true) do
  Rails::MailersController.class_eval do
    include Rails.application.routes.url_helpers

    around_action :rollback_changes, only: :preview

  private

    def rollback_changes
      ActiveRecord::Base.transaction do
        yield
      ensure
        raise ActiveRecord::Rollback
      end
    end
  end
end
