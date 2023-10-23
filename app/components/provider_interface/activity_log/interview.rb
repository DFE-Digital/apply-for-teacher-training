module ProviderInterface
  module ActivityLog
    class Interview
      attr_reader :event, :application_choice
      def initialize(event:)
        @event = event
        @application_choice = @event.audit.associated
      end

      def event_description
        user = event.user_full_name
        candidate = event.candidate_full_name

        return "#{user} set up an interview with #{candidate}" if event.audit.action == 'create'
        return "#{user} cancelled interview with #{candidate}" if event.audit.audited_changes.key?('cancelled_at')

        "#{user} updated interview with #{candidate}"
      end
    end
  end
end
