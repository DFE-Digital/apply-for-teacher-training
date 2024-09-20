ActiveSupport.on_load(:action_controller, run_once: true) do
  Rails::MailersController.class_eval do
    include Rails.application.routes.url_helpers

    before_action :set_attachments

    around_action :rollback_changes, only: :preview

  private

    def set_attachments
      @attachments = []
      @inline_attachments = []
    end

    def rollback_changes
      exception_during_preview = nil
      ActiveRecord::Base.transaction do
        yield
      rescue => e # rubocop:disable Style/RescueStandardError
        exception_during_preview = e
      ensure
        raise exception_during_preview || ActiveRecord::Rollback
      end
    end
  end
end
