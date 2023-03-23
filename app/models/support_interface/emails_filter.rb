module SupportInterface
  class EmailsFilter
    include FilterParamsHelper

    attr_reader :applied_filters

    def initialize(params:)
      @applied_filters = compact_params(params)
    end

    def filters
      @filters ||= [free_text] + [delivery_status] + [mailer]
    end

  private

    def free_text
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
      ApplicationMailer.subclasses.map(&:to_s).map(&:underscore)
    end
  end
end
