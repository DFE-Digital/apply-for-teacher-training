class FindACandidate::PopulatePoolWorker
  include Sidekiq::Worker

  sidekiq_options queue: :default

  def perform
    application_forms_eligible_for_pool = Pool::Candidates.new.application_forms_in_the_pool

    applications = application_forms_eligible_for_pool.map do |application_form|
      full_time = application_form.course_options.any? { |course_option| course_option.study_mode == 'full_time' }
      part_time = application_form.course_options.any? { |course_option| course_option.study_mode == 'part_time' }
      {
        application_form_id: application_form.id,
        candidate_id: application_form.candidate_id,
        study_mode_full_time: full_time,
        study_mode_part_time: part_time,
      }
    end

    CandidatePoolApplication.transaction do
      CandidatePoolApplication.delete_all
      CandidatePoolApplication.insert_all!(applications)
    end
  end
end
