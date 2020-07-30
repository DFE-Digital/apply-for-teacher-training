class LanguagesSectionPolicy
  def self.hide?(application_form)
    FeatureFlag.active?(:efl_section) &&
      application_form.english_main_language(fetch_database_value: true).nil?
  end
end
