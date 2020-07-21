class LanguagesSectionPolicy
  def self.hide?(application_form)
    FeatureFlag.active?(:efl_section) &&
      (
        application_form.application_choices.any?(&:unsubmitted?) ||
        application_form.english_main_language.nil?
      )
  end
end
