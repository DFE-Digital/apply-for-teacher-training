module TeacherTrainingPublicAPI
  class SyncCourses
    attr_reader :provider

    include Sidekiq::Worker
    sidekiq_options retry: 3, queue: :low_priority

    def perform(provider_id, recruitment_cycle_year)
      @provider = ::Provider.find(provider_id)

      TeacherTrainingPublicAPI::Course.where(
        year: recruitment_cycle_year,
        provider_code: @provider.code,
      ).paginate(per_page: 500).each do |course_from_api|
        create_or_update_course(course_from_api, recruitment_cycle_year)
        # update_course(course_from_api, recruitment_cycle_year)
      end
    rescue JsonApiClient::Errors::ApiError
      raise TeacherTrainingPublicAPI::SyncError
    end

  private

    # As we’re augmenting existing data, don’t create fresh incomplete courses,
    # only update those that already exist
    def update_course(course_from_api, recruitment_cycle_year)
      course = provider.courses.find_by(
        code: course_from_api.code,
        recruitment_cycle_year: recruitment_cycle_year,
      )

      if course
        course.update!(
          program_type: course_from_api.program_type,
          qualifications: course_from_api.qualifications,
        )
      end
    end

    def create_or_update_course(course_from_api, recruitment_cycle_year)
      course = provider.courses.find_or_create_by(
          code: course_from_api.code,
          recruitment_cycle_year: recruitment_cycle_year,
          ) do |new_course|
        new_course.open_on_apply = !!new_course.in_previous_cycle&.open_on_apply
      end

      assign_course_attributes(course, course_from_api, recruitment_cycle_year)
      course.save!
    def assign_course_attributes(course, course_from_api, recruitment_cycle_year)
      course.name = course_from_api.name
      course.level = course_from_api.level
      course.study_mode = course_from_api.study_mode
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
    end

    def age_range_in_years(course_from_api)
      if course_from_api.age_minimum.blank? || course_from_api.age_maximum.blank?
        nil
      else
        "#{course_from_api.age_minimum} to #{course_from_api.age_maximum}"
      end
    end