class FindInterface::SubjectDecorator < Draper::Decorator
  delegate_all

  def has_scholarship?
    object.scholarship.present?
  end

  def has_bursary?
    object.bursary_amount.present?
  end

  def has_scholarship_and_bursary?
    has_bursary? && has_scholarship?
  end

  def early_career_payments?
    object.early_career_payments.present?
  end
end
