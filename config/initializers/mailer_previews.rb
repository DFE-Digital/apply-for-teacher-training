Rails.application.config.after_initialize do
  Rails::MailersController.class_eval do
    include ActionView::Helpers::UrlHelper
    include Rails.application.routes.url_helpers

    around_action :rollback_changes, only: :preview

  private

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
