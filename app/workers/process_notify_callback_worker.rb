class ProcessNotifyCallbackWorker
  include Sidekiq::Worker

  sidekiq_options queue: :low_priority

  def perform(params)
    ProcessNotifyCallback.new(
      notify_reference: JSON.parse(params).fetch('reference'),
      status: JSON.parse(params).fetch('status'),
    ).call
  end
end
