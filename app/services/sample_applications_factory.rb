class SampleApplicationsFactory
  def self.generate_basic_applications(count, provider:)
    count.times.map do
      Satisfactory.root
        .add(:application_form)
        .with(:application_choice, course_option: provider.course_options.sample)
        .which_is(:awaiting_provider_decision)
        .create[:application_form].first
    end
  end

  def self.generate_applications(provider:, application_form_count:, application_choice_count:)
    raise ArgumentError, 'appplication_choice_count cannot be greater than 3' if application_choice_count > 3

    application_form_count.times.map do
      Satisfactory.root
        .add(:application_form)
        .with(application_choice_count, :application_choices)
        .create[:application_form].first
    end
  end
end
