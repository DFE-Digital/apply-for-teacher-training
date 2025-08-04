class Pool::Invite < ApplicationRecord
  NUMBER_OF_INVITES_TO_REMOVE_FROM_POOL = 2

  include Chased

  belongs_to :candidate
  belongs_to :application_form
  belongs_to :application_choice, optional: true
  belongs_to :provider
  belongs_to :invited_by, class_name: 'ProviderUser'
  belongs_to :course
  has_one :recruitment_cycle_timetable, primary_key: :recruitment_cycle_year, foreign_key: :recruitment_cycle_year
  has_many :application_choices, through: :application_form

  has_many :invite_decline_reasons, class_name: 'Pool::InviteDeclineReason', dependent: :destroy
  has_many :draft_invite_decline_reasons, -> { draft }, class_name: 'Pool::InviteDeclineReason', dependent: :destroy
  has_many :published_invite_decline_reasons, -> { published }, class_name: 'Pool::InviteDeclineReason', dependent: :destroy
  accepts_nested_attributes_for :invite_decline_reasons, allow_destroy: true, reject_if: :all_blank

  delegate :name, to: :provider, prefix: true
  delegate :name_code_and_study_mode, to: :course, prefix: true
  delegate :name_and_code, to: :course, prefix: true

  enum :status, {
    draft: 'draft',
    published: 'published',
  }, default: :draft

  enum :candidate_decision, {
    not_responded: 'not_responded',
    accepted: 'accepted',
    declined: 'declined',
  }, default: :not_responded

  scope :not_responded_course_open, -> { not_responded.where(course_open: true) }
  scope :actioned_by_candidate_or_course_closed, lambda {
    where(candidate_decision: %w[accepted declined])
    .or(where(course_open: false))
  }

  scope :not_sent_to_candidate, -> { where(sent_to_candidate_at: nil) }
  scope :current_cycle, -> { where(recruitment_cycle_year: RecruitmentCycleTimetable.current_year) }
  scope :with_matching_application_choices, -> { where(matching_application_choices_exists_sql) }
  scope :without_matching_application_choices, -> { where.not(matching_application_choices_exists_sql) }

  def publish_and_send_to_candidate!
    ActiveRecord::Base.transaction do
      published!
      return if sent_to_candidate?

      sent_to_candidate!
      CandidateMailer.candidate_invite(self).deliver_later
    end
  end

  def sent_to_candidate!
    update!(sent_to_candidate_at: Time.current) if sent_to_candidate_at.blank?
  end

  def sent_to_candidate?
    sent_to_candidate_at.present?
  end

  def course_closed?
    !course_open?
  end

  def matching_application_choice
    application_form.application_choices
      .visible_to_provider
      .find { |choice| [choice.course, choice.original_course, choice.current_course].any? { |c| c == course } }
  end

  def self.matching_application_choices_exists_sql
    visible_states = ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER
                       .map { |app_state| ActiveRecord::Base.connection.quote(app_state.to_s) }
                       .join(', ')

    <<~SQL.squish
      EXISTS (
        SELECT 1 FROM application_choices
        WHERE application_choices.application_form_id = pool_invites.application_form_id
          AND application_choices.status IN (#{visible_states})
          AND (
            (SELECT course_id FROM course_options WHERE id = application_choices.original_course_option_id) = pool_invites.course_id OR
            (SELECT course_id FROM course_options WHERE id = application_choices.current_course_option_id) = pool_invites.course_id OR
            (SELECT course_id FROM course_options WHERE id = application_choices.course_option_id) = pool_invites.course_id
          )
      )
    SQL
  end

  def decline_reasons_include_only_salaried?
    published_invite_decline_reasons.any?(&:reason_only_salaried?)
  end

  def decline_reasons_include_location_not_convenient?
    published_invite_decline_reasons.any?(&:reason_location_not_convenient?)
  end

  def decline_reasons_include_no_longer_interested?
    published_invite_decline_reasons.any?(&:reason_no_longer_interested?)
  end
end
