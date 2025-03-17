class UpdateOutOfDateProviderIdsOnApplicationChoices
  include Sidekiq::Worker

  def perform
    return unless out_of_date_application_choices.any?

    update_out_of_date_application_choices
  end

private

  def out_of_date_application_choices
    @_out_of_date_application_choices ||= FindApplicationChoicesWithOutOfDateProviderIds.call
  end

  def update_out_of_date_application_choices
    out_of_date_application_choices.each do |application_choice|
      update_out_of_date_provider_ids(application_choice)
    end
  end

  def update_out_of_date_provider_ids(application_choice)
    if application_choice.current_recruitment_cycle_year == current_year
      application_choice.update!(
        provider_ids: application_choice.provider_ids_for_access,
        audit_comment: 'Update out of date providers on application choice due to provider change',
      )
    else
      application_choice.update_column(:provider_ids, application_choice.provider_ids_for_access)
    end
  end

  def current_year
    @current_year ||= RecruitmentCycleTimetable.current_year
  end
end
