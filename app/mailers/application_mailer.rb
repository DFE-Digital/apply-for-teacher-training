class ApplicationMailer < Mail::Notify::Mailer
  rescue_from Notifications::Client::BadRequestError, with: :handle_notify_exception

  GENERIC_NOTIFY_TEMPLATE = '2744ea53-34f1-431f-8173-8388fadd826a'.freeze

  def handle_notify_exception(e)
    exception = case e.message
                when 'BadRequestError: Can’t send to this recipient using a team-only API key'
                  NotifyTeamOnlyAPIKeyError.new(e.message)
                else
                  NotifyOtherBadRequestError.new(e.message)
                end

    raise exception
  end

  class NotifyTeamOnlyAPIKeyError < StandardError; end

  class NotifyOtherBadRequestError < StandardError; end
end
