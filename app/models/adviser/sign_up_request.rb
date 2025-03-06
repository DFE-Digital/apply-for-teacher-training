class Adviser::SignUpRequest < ApplicationRecord
  self.table_name = 'adviser_sign_up_requests'

  belongs_to :application_form
  belongs_to :teaching_subject, class_name: 'Adviser::TeachingSubject'

  def sent_to_adviser?
    sent_to_adviser_at.present?
  end

  def sent_to_adviser!(sent_at = Time.zone.now)
    return if sent_to_adviser?

    update!(sent_to_adviser_at: sent_at)
  end
end
