module TeacherTrainingPublicAPI
  class SyncCourses
    attr_reader :provider, :run_in_background, :incremental_sync, :recruitment_cycle_year

    include Sidekiq::Worker

    sidekiq_options retry: 3, queue: :low_priority

    API_COURSE_DRAFT_STATES = %w[rolled_over draft].freeze

    def perform(provider_id, recruitment_cycle_year, incremental_sync = true, run_in_background: true)
      @provider = ::Provider.find(provider_id)
      @recruitment_cycle_year = recruitment_cycle_year
      @incremental_sync = incremental_sync
      @run_in_background = run_in_background

      provider_courses_from_api = TeacherTrainingPublicAPI::Course.where(
        year: recruitment_cycle_year,
        provider_code: @provider.code,
      ).paginate(per_page: 500)

      provider_courses_from_api.each do |course_from_api|
        course = create_or_update_course(course_from_api)
        if course.present?
          update_sites(course.id, course_from_api.application_status)
          course.published_invites.update_all(course_open: course.open? && RecruitmentCycleTimetable.current_timetable.apply_open?)
        end
      end
    rescue JsonApiClient::Errors::ApiError
      raise TeacherTrainingPublicAPI::SyncError
    end

  private

    def create_or_update_course(course_from_api)
      return if course_from_api.state.in?(API_COURSE_DRAFT_STATES)

      ::Course.transaction do
        course = provider.courses.find_or_initialize_by(
          uuid: course_from_api.uuid,
          recruitment_cycle_year:,
        )
        assign_course_attributes(course, course_from_api, recruitment_cycle_year)
        add_accredited_provider(course, course_from_api[:accredited_body_code], recruitment_cycle_year)

        notify_candidates = visa_deadline_has_changed(course)

        course.save!
        if notify_candidates == true
          CandidateMailers::EnqueueVisaSponsorshipDeadlineChangeWorker.perform_async(course.id)
        end

        course
      end
    end

    def visa_deadline_has_changed(course)
      # compare dates not timestamps
      old_date = course.visa_sponsorship_application_deadline_at_was&.to_fs(:govuk_date)
      new_date = course.visa_sponsorship_application_deadline_at&.to_fs(:govuk_date)

      course.persisted? &&
        course.visa_sponsorship_application_deadline_at_changed? &&
        old_date != new_date
    end

    def update_sites(course_id, application_status)
      job_args = [
        provider.id,
        recruitment_cycle_year,
        course_id,
        application_status,
        incremental_sync,
      ]

      if run_in_background
        TeacherTrainingPublicAPI::SyncSites.perform_async(*job_args)
      else
        TeacherTrainingPublicAPI::SyncSites.new.perform(*job_args)
      end
    end

    def assign_course_attributes(course, course_from_api, recruitment_cycle_year)
      course.accept_english_gcse_equivalency = course_from_api.accept_english_gcse_equivalency
      course.accept_gcse_equivalency = course_from_api.accept_gcse_equivalency
      course.accept_maths_gcse_equivalency = course_from_api.accept_maths_gcse_equivalency
      course.accept_pending_gcse = course_from_api.accept_pending_gcse
      course.accept_science_gcse_equivalency = course_from_api.accept_science_gcse_equivalency
      course.additional_gcse_equivalencies = course_from_api.additional_gcse_equivalencies
      course.age_range = age_range_in_years(course_from_api)
      course.applications_open_from = timetable.find_opens_at
      course.application_status = course_from_api.application_status
      course.can_sponsor_skilled_worker_visa = course_from_api.can_sponsor_skilled_worker_visa
      course.can_sponsor_student_visa = course_from_api.can_sponsor_student_visa
      course.code = course_from_api.code
      course.course_length = course_from_api.course_length
      course.degree_grade = course_from_api.degree_grade
      course.degree_subject_requirements = course_from_api.degree_subject_requirements
      course.description = course_from_api.summary
      course.exposed_in_find = course_from_api.findable
      course.fee_details = course_from_api.fee_details
      course.fee_domestic = course_from_api.fee_domestic
      course.fee_international = course_from_api.fee_international
      course.funding_type = course_from_api.funding_type
      course.level = course_from_api.level
      course.name = course_from_api.name
      course.program_type = course_from_api.program_type
      course.qualifications = course_from_api.qualifications
      course.recruitment_cycle_year = recruitment_cycle_year
      course.salary_details = course_from_api.salary_details
      course.start_date = course_from_api.start_date
      course.study_mode = study_mode(course_from_api)
      course.uuid = course_from_api.uuid
      course.withdrawn = course_from_api.state == 'withdrawn'
      course_from_api.subject_codes.each do |code|
        subject = ::Subject.find_or_initialize_by(code:)
        course.subjects << subject unless course.course_subjects.exists?(subject_id: subject.id)
      end
      course.visa_sponsorship_application_deadline_at = course_from_api.visa_sponsorship_application_deadline_at
    end

    def study_mode(course_from_api)
      course_from_api.study_mode == 'both' ? 'full_time_or_part_time' : course_from_api.study_mode
    end

    def age_range_in_years(course_from_api)
      if course_from_api.age_minimum.blank? || course_from_api.age_maximum.blank?
        nil
      else
        "#{course_from_api.age_minimum} to #{course_from_api.age_maximum}"
      end
    end

    def add_accredited_provider(course, accredited_body_code, recruitment_cycle_year)
      if accredited_body_code.present? && course.provider.code != accredited_body_code
        accredited_provider = ::Provider.find_by(code: accredited_body_code) || ::Provider.find_by(code: accredited_body_code.upcase) || ::Provider.find_by(code: accredited_body_code.downcase)
        accredited_provider = create_new_accredited_provider(accredited_body_code, recruitment_cycle_year) if accredited_provider.nil?
        course.accredited_provider = accredited_provider
        add_provider_relationship(course)
      else
        course.accredited_provider = nil
      end
    end

    def add_provider_relationship(course)
      ProviderRelationshipPermissions.find_or_create_by(
        training_provider: provider,
        ratifying_provider: course.accredited_provider,
      )
    end

    def create_new_accredited_provider(accredited_body_code, recruitment_cycle_year)
      new_provider = TeacherTrainingPublicAPI::Provider
                         .where(year: recruitment_cycle_year)
                         .find(accredited_body_code).first

      accredited_provider = ::Provider.new(code: accredited_body_code)
      accredited_provider.code = new_provider.code
      accredited_provider.name = new_provider.name
      accredited_provider.region_code = new_provider.region_code&.strip
      accredited_provider.postcode = new_provider.postcode
      accredited_provider.provider_type = new_provider.provider_type
      accredited_provider.latitude = new_provider.latitude
      accredited_provider.longitude = new_provider.longitude
      accredited_provider.save!

      accredited_provider
    end

    def timetable
      if instance_variable_defined?(:@timetable)
        @timetable
      else
        @timetable = RecruitmentCycleTimetable.find_by(recruitment_cycle_year:)
      end
    end
  end
end
