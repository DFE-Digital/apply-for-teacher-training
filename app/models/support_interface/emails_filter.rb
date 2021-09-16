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
      options = Email.distinct(:delivery_status).pluck(:delivery_status).map do |status|
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
        options: options,
      }
    end

    def mailer
      options = Email.distinct(:mailer).pluck(:mailer).map do |status|
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
        options: options,
      }
    end
  end
end
