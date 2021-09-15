module SafePerformAsync
  module ClassMethods
    def perform_async(*args)
      super(*args)
    rescue Redis::BaseError => e
      # rubocop:disable Style/RedundantSelf
      Sentry.with_scope do |scope|
        scope.set_tags(class: self.to_s) # e.g. 'SendEventsToBigquery'
        scope.set_tags(args: args.to_s) # e.g. ['{}']
        scope.set_tags(action: 'perform_async')
        Sentry.capture_exception(e)
      end
      # rubocop:enable Style/RedundantSelf
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end
end
