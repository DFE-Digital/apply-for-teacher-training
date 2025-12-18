class PreviousTeacherTraining < ApplicationRecord
  belongs_to :application_form
  belongs_to :provider, optional: true
  belongs_to :duplicate_previous_teacher_training, class_name: 'PreviousTeacherTraining', optional: true
  has_one :source_previous_teacher_training, class_name: 'PreviousTeacherTraining', foreign_key: 'duplicate_previous_teacher_training_id'

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
    dup_record.source_previous_teacher_training = self
    dup_record.save!
    dup_record
  end

  def reviewable?
    (started_yes? && [provider_name, started_at, details].all?(&:present?)) ||
      (started_no? && [provider_name, started_at, details].all?(&:nil?))
  end

  def formatted_dates
    return '' if started_at.blank? || ended_at.blank?

    "From #{started_at.to_fs(:month_and_year)} to #{ended_at.to_fs(:month_and_year)}"
  end

  def make_published
    return if published?

    ActiveRecord::Base.transaction do
      if started_no?
        application_form.previous_teacher_trainings.started_yes.destroy_all
      else
        application_form.previous_teacher_trainings.started_no.destroy_all
        old_training = source_previous_teacher_training
        old_training&.destroy!
      end
      published!
      application_form.touch
    end
  end
end
