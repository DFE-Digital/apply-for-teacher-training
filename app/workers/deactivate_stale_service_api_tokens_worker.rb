class DeactivateStaleServiceAPITokensWorker < ApplicationJob
  self.queue_adapter = :solid_queue

  queue_as :low_priority

  INACTIVE_MONTHS_AGO = 3

  def perform
    tokens.destroy_all
  end

private

  def tokens
    scope.where('used_at < ?', INACTIVE_MONTHS_AGO.months.ago)
      .or(AuthenticationToken
            .where('used_at IS NULL AND created_at < ?', INACTIVE_MONTHS_AGO.months.ago))
  end

  def scope
    AuthenticationToken.where(user_type: 'ServiceAPIUser')
  end
end
