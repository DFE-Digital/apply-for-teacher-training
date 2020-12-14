class LanguagesSectionPolicy
  def self.hide?(application_form)
    application_form.english_main_language(fetch_database_value: true).nil?
  end
end
