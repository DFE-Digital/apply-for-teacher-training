class SampleApplicationsFactory
  def self.generate_applications(count, provider:)
    count.times.map do
      Satisfactory.root
        .add(:application_form)
        .with(:application_choice, course_option: provider.course_options.sample)
        .which_is(:awaiting_provider_decision)
        .create[:application_form].first
    end
  end
end
