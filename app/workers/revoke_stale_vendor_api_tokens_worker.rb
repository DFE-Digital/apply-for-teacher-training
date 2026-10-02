class RevokeStaleVendorAPITokensWorker < ApplicationJob
  queue_as :low_priority

  INACTIVE_MONTHS_AGO = 3

  def perform
    return unless HostingEnvironment.production?

    tokens.find_each do |token|
      token.audit_comment = 'Revoked because of inactivity'
      token.hashed_token = SecureRandom.hex + Time.zone.now.to_i.to_s,
                           token.discard!
    end
  end

private

  def tokens
    scope.where(
      'last_used_at < ?', INACTIVE_MONTHS_AGO.months.ago
    ).or(
      scope.where(
        'last_used_at IS NULL AND created_at < ?', INACTIVE_MONTHS_AGO.months.ago
      ),
    )
  end

  def scope
    VendorAPIToken.undiscarded
  end
end
