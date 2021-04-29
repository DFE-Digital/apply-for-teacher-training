module TeacherTrainingPublicAPI
  class SyncCourses
    attr_reader :provider, :run_in_background
    include Rails.application.routes.url_helpers

    include Sidekiq::Worker
    sidekiq_options retry: 3, queue: :low_priority

    def perform(provider_id, recruitment_cycle_year, run_in_background: true)
      @provider = ::Provider.find(provider_id)
      @run_in_background = run_in_background

      TeacherTrainingPublicAPI::Course.where(
        year: recruitment_cycle_year,
        provider_code: @provider.code,
      ).paginate(per_page: 500).each do |course_from_api|
        ActiveRecord::Base.transaction do
          create_or_update_course(course_from_api, recruitment_cycle_year)
        end
      end
    rescue JsonApiClient::Errors::ApiError
      raise TeacherTrainingPublicAPI::SyncError
    end

  private

    def create_or_update_course(course_from_api, recruitment_cycle_year)
      open_required = false

      course = provider.courses.find_or_create_by(
        uuid: course_from_api.uuid,
        recruitment_cycle_year: recruitment_cycle_year,
      ) do |new_course|
        new_course.code = course_from_api.code
        open_required =
          HostingEnvironment.sandbox_mode? || new_course.in_previous_cycle&.open_on_apply

        if provider.any_open_courses_in_current_cycle?
          notify_of_new_course!(provider, course_from_api[:accredited_body_code])
        end
      end

      assign_course_attributes(course, course_from_api, recruitment_cycle_year)
      add_accredited_provider(course, course_from_api[:accredited_body_code], recruitment_cycle_year)
      course.save!

      course.open! if open_required

      if run_in_background
        TeacherTrainingPublicAPI::SyncSites.perform_async(provider.id, recruitment_cycle_year, course.id)
      else
        TeacherTrainingPublicAPI::SyncSites.new.perform(provider.id, recruitment_cycle_year, course.id)
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
      ProviderRelationshipPermissions.find_or_create_by!(
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

    def notify_of_new_course!(provider, accredited_provider_code)
      notification = [":seedling: #{provider.name}, which has courses open on Apply, added a new course"]
      accredited_provider = ::Provider.find_by(code: accredited_provider_code)

      if accredited_provider&.onboarded?
        notification << "It’s ratified by #{accredited_provider.name}, who have signed the DSA"
      elsif accredited_provider.present?
        notification << "It’s ratified by #{accredited_provider.name}, who have NOT signed the DSA"
      else
        notification << 'There’s no separate accredited body for this course'
      end

      SlackNotificationWorker.perform_async(
        notification.join('. ') + '.',
        support_interface_provider_courses_url(provider),
      )
    end
  end
end
