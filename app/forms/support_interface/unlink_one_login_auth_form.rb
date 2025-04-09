module SupportInterface
  class UnlinkOneLoginAuthForm
    include ActiveModel::Model

    attr_accessor :audit_comment, :candidate

    validates :audit_comment, presence: true
    validates :audit_comment, word_count: { maximum: 200 }

    def save
      return unless valid?
      return if candidate.one_login_auth.blank?

      ActiveRecord::Base.transaction do
        candidate.one_login_auth.destroy
        candidate.account_recovery_request&.destroy
        candidate.update!(
          account_recovery_status: 'not_started',
          audit_comment:,
        )
      end
    end
  end
end
