module SupportInterface
  class EmailsFilter
    include FilterParamsHelper

    FILTERABLE_BY = %i[
      to
      subject
      notify_reference
      email_body
      delivery_status
      mailer
      mail_template
      application_form_id
    ].freeze

    attr_reader :applied_filters

    def initialize(params:)
      @params = params
      params.with_defaults!(days_ago: 10)
      params[:created_since] = params.fetch(:days_ago).to_i.days.ago.beginning_of_day
      @applied_filters = compact_params(params)
    end

    def filtered?
      FILTERABLE_BY.each do |filter|
        return true if applied_filters[filter].present?
      end

      false
    end

    def filters
      @filters ||= ([application_form] + [recipient] + [subject] + [notify_reference] +
        [email_body] + [days_ago] + [delivery_status] + [mailer]).compact_blank
    end

  private

    def application_form
      return {} if @params[:application_form_id].blank?

      {
        type: :search,
        heading: 'Application form ID',
        value: applied_filters[:application_form_id]&.strip,
        name: 'application_form_id',
      }
    end

    def days_ago
      return {} unless filtered?

      {
        type: :search,
        heading: 'Days ago',
        value: applied_filters[:days_ago].to_s.strip,
        name: 'days_ago',
      }
    end

    def recipient
      {
        type: :search,
        heading: 'Recipient (To)',
        value: applied_filters[:to]&.strip,
        name: 'to',
      }
    end

    def subject
      {
        type: :search,
        heading: 'Subject',
        value: applied_filters[:subject]&.strip,
        name: 'subject',
      }
    end

    def notify_reference
      {
        type: :search,
        heading: 'Notify reference',
        value: applied_filters[:notify_reference]&.strip,
        name: 'notify_reference',
      }
    end

    def email_body
      {
        type: :search,
        heading: 'Email body',
        value: applied_filters[:email_body]&.strip,
        name: 'email_body',
      }
    end

    def delivery_status
      options = delivery_status_options.map do |status|
        {
          value: status,
          label: status.humanize,
          checked: applied_filters[:delivery_status]&.include?(status),
        }
      end

      {
        type: :checkboxes,
        heading: 'Delivery status',
        name: 'delivery_status',
        options:,
      }
    end

    def mailer
      options = mailer_options.map do |status|
        {
          value: status,
          label: status.humanize,
          checked: applied_filters[:mailer]&.include?(status),
        }
      end

      {
        type: :checkboxes,
        heading: 'Mailer',
        name: 'mailer',
        options:,
      }
    end

    def delivery_status_options
      Email.delivery_statuses.keys
    end

    def mailer_options
      %w[support_mailer referee_mailer provider_mailer candidate_mailer authentication_mailer].freeze
    end
  end
end
