class LanguagesSectionPolicy
  def self.hide?(application_form)
    FeatureFlag.active?(:efl_section) &&
      application_form[:english_main_language].nil?
  end
end
