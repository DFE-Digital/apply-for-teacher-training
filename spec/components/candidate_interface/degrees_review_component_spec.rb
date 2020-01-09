require 'rails_helper'

RSpec.describe CandidateInterface::DegreesReviewComponent do
  let(:application_form) { create(:application_form) }
  let!(:degree1) do
    application_form.application_qualifications.create(
      level: 'degree',
      qualification_type: 'BA',
      subject: 'Woof',
      institution_name: 'University of Doge',
      grade: 'upper_second',
      predicted_grade: false,
      award_year: '2008',
    )
  end
  let(:degree2) do
    {
      level: 'degree',
      qualification_type: 'BA',
      subject: 'Meow',
      institution_name: 'University of Cate',
      grade: 'First',
      predicted_grade: true,
      award_year: '2010',
    }
  end

  context 'when degrees are editable' do
    it 'renders component with correct values for a qualification' do
      result = render_inline(described_class, application_form: application_form)

      expect(result.css('.app-summary-card__title').text).to include('BA Woof')
      expect(result.css('.govuk-summary-list__key').text).to include(t('application_form.degree.qualification.label'))
      expect(result.css('.govuk-summary-list__value').to_html).to include('BA Woof<br>University of Doge')
      expect(result.css('.govuk-summary-list__actions a')[0].attr('href')).to include(
        Rails.application.routes.url_helpers.candidate_interface_degrees_edit_path(degree1),
      )
      expect(result.css('.govuk-summary-list__actions').text).to include(
        "Change #{t('application_form.degree.qualification.change_action')} for BA, Woof, University of Doge, 2008",
      )
    end

    it 'renders component with correct values for an award year' do
      result = render_inline(described_class, application_form: application_form)

      expect(result.css('.app-summary-card__title').text).to include('BA Woof')
      expect(result.css('.govuk-summary-list__key').text).to include(t('application_form.degree.award_year.review_label'))
      expect(result.css('.govuk-summary-list__value').text).to include('2008')
      expect(result.css('.govuk-summary-list__actions').text).to include(
        "Change #{t('application_form.degree.award_year.change_action')} for BA, Woof, University of Doge, 2008",
      )
    end

    it 'renders component with correct values for a known degree grade' do
      result = render_inline(described_class, application_form: application_form)

      expect(result.css('.app-summary-card__title').text).to include('BA Woof')
      expect(result.css('.govuk-summary-list__key').text).to include(t('application_form.degree.grade.review_label'))
      expect(result.css('.govuk-summary-list__value').text).to include(t('application_form.degree.grade.upper_second.label'))
      expect(result.css('.govuk-summary-list__actions').text).to include(
        "Change #{t('application_form.degree.grade.change_action')} for BA, Woof, University of Doge, 2008",
      )
    end

    it 'renders component with correct values for a predicted grade' do
      application_form.application_qualifications.create(degree2)

      result = render_inline(described_class, application_form: application_form)

      expect(result.css('.app-summary-card__title').text).to include('BA Meow')
      expect(result.css('.govuk-summary-list__value').text).to include('First (Predicted)')
    end

    it 'renders component with correct values for an other grade' do
      application_form.application_qualifications.create(
        level: 'degree',
        qualification_type: 'BA',
        subject: 'Hoot',
        institution_name: 'University of Owl',
        grade: 'Distinction',
        predicted_grade: false,
        award_year: '2010',
      )

      result = render_inline(described_class, application_form: application_form)

      expect(result.css('.app-summary-card__title').text).to include('BA Hoot')
      expect(result.css('.govuk-summary-list__value').text).to include('Distinction')
    end

    it 'renders component with correct values for multiple degrees' do
      application_form.application_qualifications.create(degree2)

      result = render_inline(described_class, application_form: application_form)

      expect(result.css('.app-summary-card__title').text).to include('BA Woof')
      expect(result.css('.app-summary-card__title').text).to include('BA Meow')
    end

    it 'renders component along with a delete link for each degree' do
      result = render_inline(described_class, application_form: application_form)

      expect(result.css('.app-summary-card__actions').text).to include(t('application_form.degree.delete'))
      expect(result.css('.app-summary-card__actions a')[0].attr('href')).to include(
        Rails.application.routes.url_helpers.candidate_interface_confirm_degrees_destroy_path(degree1),
      )
    end
  end

  context 'when degrees are not editable' do
    it 'renders component without an edit link' do
      result = render_inline(described_class, application_form: application_form, editable: false)

      expect(result.css('.app-summary-list__actions').text).not_to include('Change')
      expect(result.css('.app-summary-card__actions').text).not_to include(t('application_form.degree.delete'))
    end
  end
end
