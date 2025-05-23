class Pool::Invite < ApplicationRecord
  belongs_to :candidate
  belongs_to :provider
  belongs_to :invited_by, class_name: 'ProviderUser'
  belongs_to :course

  enum :status, {
    draft: 'draft',
    published: 'published',
  }, default: :draft

  scope :not_sent_to_candidate, -> { where(sent_to_candidate_at: nil) }

  def sent_to_candidate!
    update!(sent_to_candidate_at: Time.current) if sent_to_candidate_at.blank?
  end

  def sent_to_candidate?
    sent_to_candidate_at.present?
  end
end
