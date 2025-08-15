class Pool::InviteDeclineReason < ApplicationRecord
  belongs_to :invite, class_name: 'Pool::Invite'

  # @deprecated The status of an invite decline reason is never changed from draft. Will be removed in https://trello.com/c/F3Rvo1XB
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
