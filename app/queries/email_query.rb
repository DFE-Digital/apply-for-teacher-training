class EmailQuery
  attr_reader :params

  def initialize(params: {})
    @params = params
  end

  def self.call(...)
    new(...).call
  end

  def call
    scope = Email.order(id: :desc).includes(:application_form)
    scope = date_scope(scope)
    scope = recipient_scope(scope)
    scope = subject_scope(scope)
    scope = body_scope(scope)
    scope = delivery_status_scope(scope)
    scope = mailer_scope(scope)
    scope = mailer_template_scope(scope)
    scope = application_form_scope(scope)
    notify_scope(scope)
  end

private

  def date_scope(scope)
    return scope if params[:created_since].blank?

    scope.where('created_at >= ?', params[:created_since])
  end

  def recipient_scope(scope)
    return scope if params[:to].blank?

    scope.where('lower(emails.to) = ?', params[:to].downcase.strip)
  end

  def subject_scope(scope)
    return scope if params[:subject].blank?

    scope.where('subject ILIKE ?', "%#{params[:subject].downcase.strip}%")
  end

  def notify_scope(scope)
    return scope if params[:notify_reference].blank?

    scope.where('lower(emails.notify_reference) = ?', params[:notify_reference].downcase.strip)
  end

  def body_scope(scope)
    return scope if params[:email_body].blank?

    scope.where('body ILIKE ?', "%#{params[:email_body].downcase.strip}%")
  end

  def delivery_status_scope(scope)
    return scope if params[:delivery_status].blank?

    scope.where(delivery_status: params[:delivery_status])
  end

  def mailer_scope(scope)
    return scope if params[:mailer].blank?

    scope.where(mailer: params[:mailer])
  end

  def mailer_template_scope(scope)
    return scope if params[:mail_template].blank?

    scope.where(mail_template: params[:mail_template])
  end

  def application_form_scope(scope)
    return scope if params[:application_form_id].blank?

    scope.where(application_form_id: params[:application_form_id])
  end
end
