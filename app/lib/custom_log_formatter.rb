require 'semantic_logger'

class CustomLogFormatter < SemanticLogger::Formatters::Raw
  REDACTED = '[REDACTED]'.freeze

  def call(log, logger)
    super

    add_custom_fields
    sanitize_payload_fields
    remove_post_params
    filter_skipping_email_message

    hash.to_json
  end

private

  def add_custom_fields
    hash[:domain] = HostingEnvironment.hostname
    hash[:environment] = HostingEnvironment.environment_name
    hash[:hosting_environment] = HostingEnvironment.environment_name

    if (job_id = Thread.current[:job_id])
      hash[:job_id] = job_id
    end
    if (job_queue = Thread.current[:job_queue])
      hash[:job_queue] = job_queue
    end

    tid = Thread.current[:sidekiq_tid]
    if tid.present?
      ctx = Sidekiq::Context.current
      hash[:tid] = tid
      hash[:ctx] = ctx
    end
  end

  def sanitize_payload_fields
    if hash[:payload].present?
      hash[:payload].reject! { |key, _| SANITIZED_REQUEST_PARAMS.map(&:to_s).include?(key) }
      sanitize_mailer_subject_and_to
    end
  end

  def sanitize_mailer_subject_and_to
    if hash.dig(:payload, :subject).present?
      hash[:payload][:subject] = REDACTED
    end

    if hash.dig(:payload, :to).present?
      hash[:payload][:to] = REDACTED
    end
  end

  def filter_skipping_email_message
    if hash[:message]&.include?('Skipping email')
      hash[:message] = "Skipping email to #{REDACTED}"
    end
  end

  def remove_post_params
    return unless method_is_post_or_put_or_patch? && hash.dig(:payload, :params).present?

    hash[:payload][:params].clear
  end

  def method_is_post_or_put_or_patch?
    hash.dig(:payload, :method).in? %w[PUT POST PATCH]
  end
end
