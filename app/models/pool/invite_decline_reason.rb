class Pool::InviteDeclineReason < ApplicationRecord
  belongs_to :invite, class_name: 'Pool::Invite'

  enum :status, {
    draft: 'draft',
    published: 'published',
  }, default: :draft

  def reason_only_salaried?
    reason_inquiry.only_salaried?
  end

  def reason_location_not_convenient?
    reason_inquiry.location_not_convenient?
  end

  def reason_no_longer_interested?
    reason_inquiry.no_longer_interested?
  end

private

  def reason_inquiry
    (reason || '').inquiry
  end
end
