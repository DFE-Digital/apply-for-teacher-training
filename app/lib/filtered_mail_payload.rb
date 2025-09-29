class FilteredMailPayload
  attr_reader :formatter

  def initialize(formatter, event)
    @formatter = formatter
    @event = event
    @filtered_params = Rails.application.config.filter_parameters
    @parameter_filter = ActiveSupport::ParameterFilter.new(@filtered_params)
  end

  def filtered_payload
    {}.tap do |h|
      h[:event_name]         = @parameter_filter.filter_param('mailer.event_name', @event.name)
      h[:mailer]             = @parameter_filter.filter_param('mailer.mailer', mailer)
      h[:action]             = @parameter_filter.filter_param('mailer.action', action)
      h[:message_id]         = @parameter_filter.filter_param('mailer.message_id', @event.payload[:message_id])
      h[:perform_deliveries] = @parameter_filter.filter_param('mailer.perform_deliveries', @event.payload[:perform_deliveries])
      h[:subject]            = @parameter_filter.filter_param('mailer.subject', @event.payload[:subject])
      h[:to]                 = @parameter_filter.filter_param('mailer.to', @event.payload[:to])
      h[:from]               = @parameter_filter.filter_param('mailer.from', @event.payload[:from])
      h[:bcc]                = @parameter_filter.filter_param('mailer.bcc', @event.payload[:bcc])
      h[:cc]                 = @parameter_filter.filter_param('mailer.cc', @event.payload[:cc])
      h[:date]               = @parameter_filter.filter_param('mailer.date', date)
      h[:duration]           = @parameter_filter.filter_param('mailer.duration', @event.duration.round(2)) if log_duration?
      h[:args]               = @parameter_filter.filter_param('mailer.args', @event.payload[:args])
    end
  end

  # These are private methods on the gem rails semantic logger so
  # we need to make this filter to define the methods
  %i[mailer action date log_duration?].each do |method|
    define_method(method) do
      @formatter.send(method)
    end
  end
end
