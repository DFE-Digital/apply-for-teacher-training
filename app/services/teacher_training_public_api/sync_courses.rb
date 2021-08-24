module TeacherTrainingPublicAPI
  class SyncCourses
    include FullSyncErrorHandler

    attr_reader :provider, :run_in_background

    include Sidekiq::Worker
    sidekiq_options retry: 3, queue: :low_priority

    def perform(provider_id, recruitment_cycle_year, incremental_sync = true, run_in_background: true)
      @provider = ::Provider.find(provider_id)
      @run_in_background = run_in_background
      @incremental_sync = incremental_sync
      @updates = {}

      scope = TeacherTrainingPublicAPI::Course.where(
        year: recruitment_cycle_year,
        provider_code: @provider.code,
      ).paginate(per_page: 500)

      scope.each do |course_from_api|
        ActiveRecord::Base.transaction do
          create_or_update_course(course_from_api, recruitment_cycle_year, @incremental_sync)
        end
      end

      raise_update_error(@updates)
    rescue JsonApiClient::Errors::ApiError
      raise TeacherTrainingPublicAPI::SyncError
    end

  private

    def create_or_update_course(course_from_api, recruitment_cycle_year, incremental_sync)
      course = provider.courses.find_or_initialize_by(
        uuid: course_from_api.uuid,
        recruitment_cycle_year: recruitment_cycle_year,
      )

      assign_course_attributes(course, course_from_api, recruitment_cycle_year)
      add_accredited_provider(course, course_from_api[:accredited_body_code], recruitment_cycle_year)

      new_course = course.new_record?
      @updates.merge!(courses: true) if !incremental_sync && course.changed?

      course.save!

      if new_course
        SetOpenOnApplyForNewCourse.new(course).call
      end

      if run_in_background
        TeacherTrainingPublicAPI::SyncSites.perform_async(provider.id, recruitment_cycle_year, course.id, incremental_sync)
      else
        TeacherTrainingPublicAPI::SyncSites.new.perform(provider.id, recruitment_cycle_year, course.id, incremental_sync)
      end
    end

    def assign_course_attributes(course, course_from_api, recruitment_cycle_year)
      course.uuid = course_from_api.uuid
      course.code = course_from_api.code
      course.name = course_from_api.name
      course.level = course_from_api.level
      course.study_mode = study_mode(course_from_api)
      course.description = course_from_api.summary
      course.start_date = course_from_api.start_date
      course.course_length = course_from_api.course_length
      course.recruitment_cycle_year = recruitment_cycle_year
      course.exposed_in_find = course_from_api.findable
      course.funding_type = course_from_api.funding_type
      course.program_type = course_from_api.program_type
      course.age_range = age_range_in_years(course_from_api)
      course.withdrawn = course_from_api.state == 'withdrawn'
      course.qualifications = course_from_api.qualifications
      course_from_api.subject_codes.each do |code|
        subject = ::Subject.find_or_initialize_by(code: code)
        course.subjects << subject unless course.course_subjects.exists?(subject_id: subject.id)
      end
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
        accredited_provider = ::Provider.find_by(code: accredited_body_code)
        accredited_provider = create_new_accredited_provider(accredited_body_code, recruitment_cycle_year) if accredited_provider.nil?

        course.accredited_provider = accredited_provider
        add_provider_relationship(course)
      else
        course.accredited_provider = nil
      end
    end

    def add_provider_relationship(course)
      provider_relationship_permission = ProviderRelationshipPermissions.find_or_initialize_by(
        training_provider: provider,
        ratifying_provider: course.accredited_provider,
      )

      permission_changed = provider_relationship_permission.new_record?
      provider_relationship_permission.save!

      if !@incremental_sync && permission_changed
        @updates.merge!(provider_relationship_permission: true)
      end
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
  end
end
