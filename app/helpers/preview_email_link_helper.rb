module PreviewEmailLinkHelper
  def preview_email_link(title, path:)
    if Rails.application.config.action_mailer.show_previews
      govuk_link_to(
        title,
        url_for(controller: 'rails/mailers', action: 'preview', path:),
      )
    else
      title
    end
  end
end
