module SupportInterface
  class ApplicationsFilter
    include Pagy::Backend
    include FilterParamsHelper

    PAGY_PER_PAGE = 30

    attr_reader :applied_filters

    def initialize(params:)
      @applied_filters = compact_params(params)
    end

    def filter_records(application_forms)
      if applied_filters[:q].present?
        application_forms = application_forms.where("CONCAT(application_forms.first_name, ' ', application_forms.last_name, ' ', candidates.email_address, ' ', application_forms.support_reference) ILIKE ?", "%#{applied_filters[:q].squish}%")
      end

      if applied_filters[:application_choice_id].present?
        application_forms = application_forms.joins(:application_choices).where(application_choices: { id: applied_filters[:application_choice_id].to_i })
      end

      if applied_filters[:phase].present?
        application_forms = application_forms.where(phase: applied_filters[:phase])
      end

      if applied_filters[:interviews].present?
        application_forms = application_forms.joins(application_choices: [:interviews]).group('id')
      end

      if applied_filters[:year].present?
        application_forms = application_forms.where(recruitment_cycle_year: applied_filters[:year])
      end

      if applied_filters[:status].present?
        application_forms = application_forms.joins(:application_choices).where(application_choices: { status: applied_filters[:status] })
      end

      if applied_filters[:subject].present?
        application_forms = application_forms.joins(courses: :subjects).where(subjects: { name: applied_filters[:subject] })
      end

      if applied_filters[:nationality].present? && applied_filters[:nationality].one?
        is_international = ActiveModel::Type::Boolean.new.cast(applied_filters[:nationality].first)

        application_forms = if is_international
                              application_forms.where.not(first_nationality: %w[British Irish])
                            else
                              application_forms.where(first_nationality: %w[British Irish])
                            end
      end

      if applied_filters[:provider_id]
        application_forms = application_forms
          .joins(:application_choices)
          .where('application_choices.provider_ids @> ?', "{#{applied_filters[:provider_id]}}")
      end

      pagy(
        application_forms
          .joins(:candidate)
          .preload(
            :candidate,
            application_choices: { current_course_option: { course: :provider } },
          )
          .distinct
          .order(updated_at: :desc, id: :desc),
        page: applied_filters[:page] || 1,
        limit: PAGY_PER_PAGE,
      )
    end

    def filters
      @filters ||= [search_filter, search_by_application_choice_filter, year_filter, phase_filter, interviews_filter, status_filter, subject_filter, nationality_filter]
    end

  private

    def year_filter
      cycle_options = RecruitmentCycleYearsPresenter.call(with_current_indicator: true).map do |year, label|
        {
          value: year,
          label:,
          checked: applied_filters[:year]&.include?(year),
        }
      end

      {
        type: :checkboxes,
        heading: 'Recruitment cycle',
        name: 'year',
        options: cycle_options,
      }
    end

    def search_filter
      {
        type: :search,
        heading: 'Name, email or reference',
        value: applied_filters[:q],
        name: 'q',
      }
    end

    def search_by_application_choice_filter
      {
        type: :search,
        css_classes: 'govuk-input--width-5',
        heading: 'Provider application number',
        value: applied_filters[:application_choice_id],
        name: 'application_choice_id',
      }
    end

    def phase_filter
      {
        type: :checkboxes,
        heading: 'Phase',
        name: 'phase',
        options: [
          {
            value: 'apply_1',
            label: 'Apply 1',
            checked: applied_filters[:phase]&.include?('apply_1'),
          },
          {
            value: 'apply_2',
            label: 'Apply 2',
            checked: applied_filters[:phase]&.include?('apply_2'),
          },
        ],
      }
    end

    def interviews_filter
      {
        type: :checkboxes,
        heading: 'Interviews',
        name: 'interviews',
        options: [
          {
            value: 'has_interviews',
            label: 'Has interviews',
            checked: applied_filters[:interviews]&.include?('has_interviews'),
          },
        ],
      }
    end

    def subject_filter
      subject_options = MinisterialReport::SUBJECTS.map do |subject, _|
        {
          value: subject.to_s.humanize,
          label: subject.to_s.humanize,
          checked: applied_filters[:subject]&.include?(subject.to_s.humanize),
        }
      end
      {
        type: :checkbox_filter,
        heading: 'Subject',
        name: 'subject',
        options: subject_options,
      }
    end

    def nationality_filter
      {
        type: :checkboxes,
        heading: 'Nationality',
        name: 'nationality',
        options: [
          {
            value: false,
            label: 'Home',
            checked: applied_filters[:nationality]&.include?('false'),
          },
          {
            value: true,
            label: 'International',
            checked: applied_filters[:nationality]&.include?('true'),
          },
        ],
      }
    end

    def status_filter
      {
        type: :checkboxes,
        heading: 'Status',
        name: 'status',
        options: [
          {
            value: 'unsubmitted',
            label: 'Not submitted yet',
            checked: applied_filters[:status]&.include?('unsubmitted'),
          },
          {
            value: 'awaiting_provider_decision',
            label: 'Awaiting provider decision',
            checked: applied_filters[:status]&.include?('awaiting_provider_decision'),
          },
          {
            value: 'interviewing',
            label: 'Interviewing',
            checked: applied_filters[:status]&.include?('interviewing'),
          },
          {
            value: 'offer',
            label: 'Offer made',
            checked: applied_filters[:status]&.include?('offer'),
          },
          {
            value: 'pending_conditions',
            label: 'Conditions pending',
            checked: applied_filters[:status]&.include?('pending_conditions'),
          },
          {
            value: 'recruited',
            label: 'Recruited',
            checked: applied_filters[:status]&.include?('recruited'),
          },
          {
            value: 'rejected',
            label: 'Rejected',
            checked: applied_filters[:status]&.include?('rejected'),
          },
          {
            value: 'declined',
            label: 'Offer declined',
            checked: applied_filters[:status]&.include?('declined'),
          },
          {
            value: 'withdrawn',
            label: 'Withdrawn',
            checked: applied_filters[:status]&.include?('withdrawn'),
          },
          {
            value: 'conditions_not_met',
            label: 'Conditions not met',
            checked: applied_filters[:status]&.include?('conditions_not_met'),
          },
          {
            value: 'offer_withdrawn',
            label: 'Offer withdrawn',
            checked: applied_filters[:status]&.include?('offer_withdrawn'),
          },
          {
            value: 'offer_deferred',
            label: 'Offer deferred',
            checked: applied_filters[:status]&.include?('offer_deferred'),
          },
          {
            value: 'inactive',
            label: 'Inactive',
            checked: applied_filters[:status]&.include?('inactive'),
          },
        ],
      }
    end
  end
end
