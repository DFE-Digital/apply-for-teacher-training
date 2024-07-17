##
# Presenter class for single text rejection reason from ApplicationChoice#rejection_reason.
# See https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/docs/app_concepts/reasons-for-rejection.md
#
class RejectionReasons
  class RejectionReasonPresenter < SimpleDelegator
    def rejection_reasons
      return nil unless rejection_reason?

      { I18n.t('reasons_for_rejection.single_rejection_reason.title') => [rejection_reason] }
    end

    def reasons
      raise NotImplementedError '#reasons not implemented for single rejection reason'
    end
  end
end
