class DeactivateStaleServiceAPITokensWorker < ApplicationJob
  queue_as :low_priority

  INACTIVE_MONTHS_AGO = 3

  def perform
    tokens.destroy_all
  end

private

  def tokens
    scope.where('used_at < ?', INACTIVE_MONTHS_AGO.months.ago)
      .or(scope.where('used_at IS NULL AND created_at < ?', INACTIVE_MONTHS_AGO.months.ago))
  end

  def scope
    AuthenticationToken.where(user_type: 'ServiceAPIUser')
  end
end
