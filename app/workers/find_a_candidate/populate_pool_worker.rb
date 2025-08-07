class FindACandidate::PopulatePoolWorker
  include Sidekiq::Worker

  sidekiq_options queue: :default

  def perform
    if CandidatePoolApplication.closed?
      CandidatePoolApplication.delete_all
    else
      application_forms_eligible_for_pool = Pool::Candidates.new.application_forms_in_the_pool

      applications = application_forms_eligible_for_pool
                       .joins(application_choices: { course_option: { course: :subjects } })
                       .joins(candidate: :published_opt_in_preferences)
                       .left_joins(:not_responded_published_invites)
                       .where.not(application_choices: { status: 'unsubmitted' })
                       .select(
                         'application_forms.id AS application_form_id',
                         'application_forms.candidate_id AS candidate_id',
                         "BOOL_OR(course_options.study_mode = 'full_time') AS study_mode_full_time",
                         "BOOL_OR(course_options.study_mode = 'part_time') AS study_mode_part_time",
                         "BOOL_OR(courses.program_type != 'TDA') AS course_type_postgraduate",
                         "BOOL_OR(courses.program_type = 'TDA') AS course_type_undergraduate",
                         'ARRAY_AGG(DISTINCT subjects.id) AS subject_ids',
                         "COALESCE(ARRAY_AGG(DISTINCT courses.provider_id) FILTER (WHERE application_choices.status = 'rejected'), '{}') AS rejected_provider_ids",
                         "MAX(CASE WHEN application_forms.right_to_work_or_study = 'no' OR (application_forms.right_to_work_or_study = 'yes' AND application_forms.immigration_status IN ('student_visa', 'skilled_worker_visa')) THEN 1 ELSE 0 END) = 1 AS needs_visa",
                         'CURRENT_TIMESTAMP as created_at',
                         'CURRENT_TIMESTAMP as updated_at',
                         "MAX(CASE WHEN candidate_preferences.funding_type = 'fee'
                          OR EXISTS (
                               SELECT 1
                               FROM   application_forms
                               WHERE  courses.funding_type = 'fee'
                               AND    (candidate_preferences.funding_type = 'fee'
                                       OR candidate_preferences.funding_type IS NULL)
                          )
                         THEN 1
                         ELSE 0
                       END) = 1 AS course_funding_type_fee",
                       )
                       .group(:id)
                       .having("COUNT(DISTINCT pool_invites.id) < #{Pool::Invite::NUMBER_OF_INVITES_TO_REMOVE_FROM_POOL}")

      insert_all_from_eligible_sql = <<~SQL
        INSERT INTO candidate_pool_applications (
          application_form_id,
          candidate_id,
          study_mode_full_time,
          study_mode_part_time,
          course_type_postgraduate,
          course_type_undergraduate,
          subject_ids,
          rejected_provider_ids,
          needs_visa,
          created_at,
          updated_at,
          course_funding_type_fee
        )
        #{applications.to_sql}
      SQL

      CandidatePoolApplication.transaction do
        CandidatePoolApplication.delete_all
        ActiveRecord::Base.connection.execute(insert_all_from_eligible_sql)
      end
    end
  end
end
