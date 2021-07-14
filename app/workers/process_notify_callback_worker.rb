class ProcessNotifyCallbackWorker
  include Sidekiq::Worker

  def perform(params)
    ProcessNotifyCallback.new(
      notify_reference: params.fetch('reference'),
      status: params.fetch('status'),
    ).call
  end
end
