class FindACandidate::PopulatePoolWorker
  include Sidekiq::Worker

  sidekiq_options queue: :default

  def perform
    application_forms_eligible_for_pool = Pool::Candidates.new.application_forms_in_the_pool

    applications = application_forms_eligible_for_pool.map do |application_form|
      full_time = application_form.course_options.any? { |course_option| course_option.study_mode == 'full_time' }
      part_time = application_form.course_options.any? { |course_option| course_option.study_mode == 'part_time' }

      undergraduate_program_type = 'teacher_degree_apprenticeship'
      postgraduate_program_types = Course.program_types.except('teacher_degree_apprenticeship').keys

      postgraduate = application_form.course_options.any? { |course_option| postgraduate_program_types.include?(course_option.course.program_type) }
      undergraduate = application_form.course_options.any? { |course_option| course_option.course.program_type == undergraduate_program_type }
      subject_ids = application_form.courses.flat_map do |course|
        course.subjects.pluck(:id)
      end.uniq

      {
        application_form_id: application_form.id,
        candidate_id: application_form.candidate_id,
        study_mode_full_time: full_time,
        study_mode_part_time: part_time,
        course_type_postgraduate: postgraduate,
        course_type_undergraduate: undergraduate,
        subject_ids: subject_ids,
      }
    end

    CandidatePoolApplication.transaction do
      CandidatePoolApplication.delete_all
      CandidatePoolApplication.insert_all!(applications)
    end
  end
end
