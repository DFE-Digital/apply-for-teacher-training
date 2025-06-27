class Pool::Invite < ApplicationRecord
  belongs_to :candidate
  belongs_to :application_form
  belongs_to :provider
  belongs_to :invited_by, class_name: 'ProviderUser'
  belongs_to :course
  has_one :recruitment_cycle_timetable, primary_key: :recruitment_cycle_year, foreign_key: :recruitment_cycle_year

  enum :status, {
    draft: 'draft',
    published: 'published',
  }, default: :draft

  scope :not_sent_to_candidate, -> { where(sent_to_candidate_at: nil) }
  scope :current_cycle, -> { where(recruitment_cycle_year: RecruitmentCycleTimetable.current_year) }
  scope :with_matching_application_choices, -> { where(matching_application_choices_exists_sql) }
  scope :without_matching_application_choices, -> { where.not(matching_application_choices_exists_sql) }

  def sent_to_candidate!
    update!(sent_to_candidate_at: Time.current) if sent_to_candidate_at.blank?
  end

  def sent_to_candidate?
    sent_to_candidate_at.present?
  end

  def application_choice_with_course_match_visible_to_provider
    # If you are using this method when iterating over lots of records, make sure to eager load first.
    # Otherwise, you'll have an expensive N + 1 problem.
    # eg
    # .includes(application_forms: {
    #     application_choices: [
    #       { :original_course_option: :current_course_option },
    #     ],
    #   },
    # })
    @course_match ||= application_form.application_choices.visible_to_provider.find do |choice|
      choice.current_course_option&.course_id == course_id ||
        choice.original_course_option&.course_id == course_id
    end
  end

  def self.matching_application_choices_exists_sql
    visible_states = ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER.map do |state|
      ActiveRecord::Base.connection.quote(state.to_s)
    end.join(', ')

    <<~SQL.squish
      EXISTS (
        SELECT 1 FROM application_choices
        LEFT JOIN course_options original_options ON original_options.id = application_choices.original_course_option_id
        LEFT JOIN courses original_courses ON original_courses.id = original_options.course_id
        LEFT JOIN course_options current_options ON current_options.id = application_choices.current_course_option_id
        LEFT JOIN courses current_courses ON current_courses.id = current_options.course_id
        WHERE application_choices.application_form_id = pool_invites.application_form_id
          AND application_choices.status IN (#{visible_states})
          AND (
            original_courses.id = pool_invites.course_id OR
            current_courses.id = pool_invites.course_id
          )
      )
    SQL
  end
end
