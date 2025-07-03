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
      @provider_user.provider_user_filters.find_or_create_by(kind:).tap do |user_filter|
        user_filter.update!(
          filters: {
            courses: @filter_params.fetch('courses', []).compact_blank.map(&:to_i),
            status: @filter_params.fetch('status', []).compact_blank,
          }.compact_blank,
        )
      end
    end

    def use_existing_filter
      @provider_user.provider_user_filters.find_or_initialize_by(kind:)
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
        options: possible_statuses.map do |status|
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
      return invites if status_filter.blank? || status_filter.sort == possible_statuses

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
                         .includes(:course, :application_form)
                         .order(created_at: :desc)
                         .select(matching_choice_sql)
    end

    def kind
      'find_candidates_invited'
    end

    def status_filter
      @status_filter ||=  @provider_user_filter.filters.fetch('status', [])
    end

    def courses_filter
      @courses_filter ||= @provider_user_filter.filters.fetch('courses', [])
    end

    def matching_choice_sql
      visible_states = ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER
                           .map { |s| ActiveRecord::Base.connection.quote(s.to_s) }
                           .join(', ')

      <<~SQL.squish
        pool_invites.*,
        (
          SELECT application_choices.id
          FROM application_choices
          WHERE application_choices.application_form_id = pool_invites.application_form_id
            AND application_choices.status IN (#{visible_states})
            AND (
              (SELECT course_id FROM course_options WHERE id = application_choices.original_course_option_id) = pool_invites.course_id OR
              (SELECT course_id FROM course_options WHERE id = application_choices.current_course_option_id) = pool_invites.course_id OR
              (SELECT course_id FROM course_options WHERE id = application_choices.course_option_id) = pool_invites.course_id
            )
          ORDER BY application_choices.id ASC
          LIMIT 1
        ) AS matching_choice_id
      SQL
    end
  end
end
