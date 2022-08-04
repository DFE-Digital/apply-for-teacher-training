class RejectedApplicationChoicePresenter < SimpleDelegator
  delegate :rejection_reasons, :reasons, to: :presenter

  def presenter
    presenter_class.new(__getobj__)
  end

private

  def presenter_class
    case rejection_reasons_type
    when 'rejection_reasons', 'vendor_api_rejection_reasons'
      RejectionReasons::RejectionReasonsPresenter
    when 'reasons_for_rejection'
      RejectionReasons::ReasonsForRejectionPresenter
    else
      RejectionReasons::RejectionReasonPresenter
    end
  end
end
