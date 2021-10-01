module ApplicationFilterHelper
  def year_filter
    cycle_options = RecruitmentCycle::CYCLES.map do |year, label|
      {
        value: year,
        label: label,
        checked: applied_filters[:year]&.include?(year),
      }
    end

    {
      type: :checkboxes,
      heading: 'Recruitment cycle year',
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
      heading: 'Provider application ID',
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
          label: 'Pending conditions',
          checked: applied_filters[:status]&.include?('pending_conditions'),
        },
        {
          value: 'conditions_met',
          label: 'Conditions met',
          checked: applied_filters[:status]&.include?('conditions_met'),
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
      ],
    }
  end
end
