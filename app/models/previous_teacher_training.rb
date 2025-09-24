class PreviousTeacherTraining < ApplicationRecord
  belongs_to :application_form
  belongs_to :provider, optional: true

  enum :started, {
    yes: 'yes',
    no: 'no',
  }, prefix: true

  enum :status, {
    draft: 'draft',
    published: 'published',
  }, default: 'draft'

  def create_draft_dup!
    dup_record = dup
    dup_record.status = 'draft'

    dup_record.save!
    dup_record
  end

  def reviewable?
    (started_yes? && [provider_name, started_at, details].all?(&:present?)) ||
      (started_no? && [provider_name, started_at, details].all?(&:nil?))
  end

  def formatted_dates
    "From #{started_at.to_fs(:month_and_year)} to #{ended_at.to_fs(:month_and_year)}"
  end
end
