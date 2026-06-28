class ProcessNotifyCallbackWorker < ApplicationJob
  self.queue_adapter = :solid_queue

  queue_as :low_priority

  def perform(params)
    ProcessNotifyCallback.new(
      notify_reference: params.fetch('reference'),
      status: params.fetch('status'),
    ).call
  end
end
