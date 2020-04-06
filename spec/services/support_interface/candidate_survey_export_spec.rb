require 'rails_helper'

RSpec.describe SupportInterface::CandidateSurveyExport do
  describe '#call' do
    it 'returns a hash of candidates satisfaction survey answers' do
      application_form1 = create(:completed_application_form, :with_survey_completed)
      application_form2 = create(:completed_application_form, :with_survey_completed)
      application_form3 = create(:completed_application_form, :with_survey_completed)
      create(:completed_application_form)


      expect(described_class.new.call).to match_array([return_expected_hash(application_form1), return_expected_hash(application_form2), return_expected_hash(application_form3)])
    end
  end

private

  def return_expected_hash(application_form)
    survey = application_form.satisfaction_survey

    {
      'Name' => application_form.full_name,
      'Email_address' => application_form.candidate.email_address,
      'Phone number' => application_form.phone_number,
      I18n.t('page_titles.recommendation') => survey[I18n.t('page_titles.recommendation').to_s],
      I18n.t('page_titles.complexity') => survey[I18n.t('page_titles.complexity').to_s],
      I18n.t('page_titles.ease_of_use') => survey[I18n.t('page_titles.ease_of_use').to_s],
      I18n.t('page_titles.help_needed') => survey[I18n.t('page_titles.help_needed').to_s],
      I18n.t('page_titles.organisation') => survey[I18n.t('page_titles.organisation').to_s],
      I18n.t('page_titles.consistency') => survey[I18n.t('page_titles.consistency').to_s],
      I18n.t('page_titles.adaptability') => survey[I18n.t('page_titles.adaptability').to_s],
      I18n.t('page_titles.awkward') => survey[I18n.t('page_titles.awkward').to_s],
      I18n.t('page_titles.confidence') => survey[I18n.t('page_titles.confidence').to_s],
      I18n.t('page_titles.needed_additional_learning') => survey[I18n.t('page_titles.needed_additional_learning').to_s],
      I18n.t('page_titles.improvements') => survey[I18n.t('page_titles.improvements').to_s],
      I18n.t('page_titles.other_information') => survey[I18n.t('page_titles.other_information').to_s],
      I18n.t('page_titles.contact') => survey[I18n.t('page_titles.contact').to_s],
    }
  end
end
