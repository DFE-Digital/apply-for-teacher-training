module SupportInterface
  class EmailsFilter
    include FilterParamsHelper

    attr_reader :applied_filters

    def initialize(params:)
      params.with_defaults!(days_ago: 10)
      params[:created_since] = params.fetch(:days_ago).to_i.days.ago.beginning_of_day
      @applied_filters = compact_params(params)
    end

    def filtered?
      filters.pluck(:name).each do |filter|
        return true if applied_filters[filter].present?
      end

      false
    end

    def filters
      @filters ||= [recipient] + [subject] + [notify_reference] +
        [email_body] + [free_text] + [delivery_status] + [mailer]
    end

  private

    def recipient
      {
        type: :search,
        heading: 'Recipient (To)',
        value: applied_filters[:to],
        name: 'to',
      }
    end

    def subject
      {
        type: :search,
        heading: 'Subject',
        value: applied_filters[:subject],
        name: 'subject',
      }
    end

    def notify_reference
      {
        type: :search,
        heading: 'Notify reference',
        value: applied_filters[:notify_reference],
        name: 'notify_reference',
      }
    end

    def email_body
      {
        type: :search,
        heading: 'Email body',
        value: applied_filters[:email_body],
        name: 'email_body',
      }
    end

    def free_text
      return {}

      {
        type: :search,
        heading: 'Search',
        value: applied_filters[:q],
        name: 'q',
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
