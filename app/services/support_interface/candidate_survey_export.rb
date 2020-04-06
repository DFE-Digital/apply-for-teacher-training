module SupportInterface
  class CandidateSurveyExport
    def call
      application_forms = ApplicationForm.where.not(satisfaction_survey: nil)

      output = []

      application_forms.includes(:candidate).each do |application_form|
        survey = application_form.satisfaction_survey

        answer = {
          'Name' => application_form.full_name,
          'Email_address' => application_form.candidate.email_address,
          'Phone number' => application_form.phone_number,
          I18n.t('page_titles.recommendation') => survey[I18n.t('page_titles.recommendation')],
          I18n.t('page_titles.complexity') => survey[I18n.t('page_titles.complexity')],
          I18n.t('page_titles.ease_of_use') => survey[I18n.t('page_titles.ease_of_use')],
          I18n.t('page_titles.help_needed') => survey[I18n.t('page_titles.help_needed')],
          I18n.t('page_titles.organisation') => survey[I18n.t('page_titles.organisation')],
          I18n.t('page_titles.consistency') => survey[I18n.t('page_titles.consistency')],
          I18n.t('page_titles.adaptability') => survey[I18n.t('page_titles.adaptability')],
          I18n.t('page_titles.awkward') => survey[I18n.t('page_titles.awkward')],
          I18n.t('page_titles.confidence') => survey[I18n.t('page_titles.confidence')],
          I18n.t('page_titles.needed_additional_learning') => survey[I18n.t('page_titles.needed_additional_learning')],
          I18n.t('page_titles.improvements') => survey[I18n.t('page_titles.improvements')],
          I18n.t('page_titles.other_information') => survey[I18n.t('page_titles.other_information')],
          I18n.t('page_titles.contact') => survey[I18n.t('page_titles.contact')],
        }

        output << answer
      end

      output
    end
  end
end
