module ProviderInterface
  class CandidateInvitesFilter
    def initialize(filter_params:, provider_user:)
      @filter_params = filter_params
      @provider_user = provider_user
    end

    def applied_filters
      @provider_user_filter = @filter_params.present? ? use_filter_with_new_params : use_existing_filter

      invites = filter_by_course(all_invites)
      filter_by_status(invites)
    end

    def filters
      [course_filter_options, status_filter_options]
    end

    def candidate_count
      applied_filters.pluck(:candidate_id).uniq.size
    end

    def show_bottom_button?
      true
    end

  private

    def use_filter_with_new_params
      @provider_user.provider_user_filters.find_or_create_by(path:).tap do |user_filter|
        user_filter.update!(
          filters: {
            courses: @filter_params.fetch('courses', []).compact_blank.map(&:to_i),
            status: @filter_params.fetch('status', []).compact_blank,
          }.compact_blank,
        )
      end
    end

    def use_existing_filter
      @provider_user.provider_user_filters.find_or_initialize_by(path:)
    end

    def course_filter_options
      {
        type: :checkboxes,
        heading: 'Courses',
        name: 'courses',
        options: relevant_courses.map do |course|
          {
            value: course.id,
            label: course.name_and_code,
            checked: courses_filter.include?(course.id),
          }
        end,
      }
    end

    def relevant_courses
      @relevant_courses ||= Course.where(id: all_invites.pluck(:course_id).uniq).order(:name)
    end

    def status_filter_options
      {
        type: :checkboxes,
        heading: 'Status',
        name: 'status',
        options: %w[application_received invited].map do |status|
          {
            value: status,
            label: I18n.t("provider_interface.candidate_pool.invites.index.#{status}"),
            checked: status_filter.include?(status),
          }
        end,
      }
    end

    def possible_statuses
      %w[application_received invited].sort
    end

    def filter_by_course(invites)
      return invites if courses_filter.blank?

      invites.where(course_id: courses_filter)
    end

    def filter_by_status(invites)
      return invites if status_filter.blank?
      return invites if status_filter.sort == possible_statuses

      if status_filter.include?('invited')
        invites.without_matching_application_choices
      elsif status_filter.include?('application_received')
        invites.with_matching_application_choices
      end
    end

    def all_invites
      @all_invites ||= Pool::Invite
                         .published
                         .current_cycle
                         .where(provider: @provider_user.providers)
                         .order(:candidate_id)
                         .includes(candidate: {
                           application_forms: {
                             application_choices: [
                               { original_course_option: :course },
                               { current_course_option: :course },
                             ],
                           },
                         })
    end

    def path
      @path ||= Rails.application.routes.url_helpers.provider_interface_candidate_pool_invites_path
    end

    def status_filter
      @provider_user_filter.filters.fetch('status', [])
    end

    def courses_filter
      @provider_user_filter.filters.fetch('courses', [])
    end
  end
end
