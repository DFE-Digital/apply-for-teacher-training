require 'rails_helper'

RSpec.describe CandidateInterface::OtherQualificationsReviewComponent do
  let(:application_form) do
    create(:application_form) do |form|
      form.application_qualifications.create(
        id: 1,
        level: 'other',
        qualification_type: 'A-Level',
        subject: 'Making Doggo Sounds',
        institution_name: 'Doggo Sounds College',
        grade: 'A',
        predicted_grade: false,
        award_year: '2012',
      )
      form.application_qualifications.create(
        id: 2,
        level: 'other',
        qualification_type: 'A-Level',
        subject: 'Making Cat Sounds',
      )
    end
  end

  context 'when other qualifications are editable' do
    it 'renders component with correct values for a qualification' do
      result = render_inline(described_class, application_form: application_form)

      expect(result.css('.app-summary-card__title').text).to include('A-Level Making Doggo Sounds')
      expect(result.css('.govuk-summary-list__key').text).to include(t('application_form.other_qualification.qualification.label'))
      expect(result.css('.govuk-summary-list__key').text).to include(t('application_form.other_qualification.institution.label'))
      expect(result.css('.govuk-summary-list__value').to_html).to include('A-Level Making Doggo Sounds')
      expect(result.css('.govuk-summary-list__value').to_html).to include('Doggo Sounds College')
      expect(result.css('.govuk-summary-list__actions a')[0].attr('href')).to include(
        Rails.application.routes.url_helpers.candidate_interface_edit_other_qualification_path(1),
      )
      expect(result.css('.govuk-summary-list__actions').text).to include("Change #{t('application_form.other_qualification.institution.change_action')}")
    end

    it 'renders component with correct values for an award year' do
      result = render_inline(described_class, application_form: application_form)

      expect(result.css('.app-summary-card__title').text).to include('A-Level Making Doggo Sounds')
      expect(result.css('.govuk-summary-list__key').text).to include(t('application_form.other_qualification.award_year.review_label'))
      expect(result.css('.govuk-summary-list__value').text).to include('2012')
      expect(result.css('.govuk-summary-list__actions').text).to include("Change #{t('application_form.other_qualification.award_year.change_action')}")
    end

    it 'renders component with correct values for a grade' do
      result = render_inline(described_class, application_form: application_form)

      expect(result.css('.app-summary-card__title').text).to include('A-Level Making Doggo Sounds')
      expect(result.css('.govuk-summary-list__key').text).to include(t('application_form.other_qualification.grade.label'))
      expect(result.css('.govuk-summary-list__value').text).to include('A')
      expect(result.css('.govuk-summary-list__actions').text).to include("Change #{t('application_form.other_qualification.grade.change_action')}")
    end

    it 'renders component with correct values for multiple qualifications' do
      result = render_inline(described_class, application_form: application_form)

      expect(result.css('.app-summary-card__title').text).to include('A-Level Making Doggo Sounds')
      expect(result.css('.app-summary-card__title').text).to include('A-Level Making Cat Sounds')
    end

    it 'renders component along with a delete link for each qualification' do
      result = render_inline(described_class, application_form: application_form)

      expect(result.css('.app-summary-card__actions').text).to include(t('application_form.other_qualification.delete'))
      expect(result.css('.app-summary-card__actions a')[1].attr('href')).to include(
        Rails.application.routes.url_helpers.candidate_interface_confirm_destroy_other_qualification_path(2),
      )
    end

    it 'renders component with ids for qualification, institution and year rows' do
      result = render_inline(described_class, application_form: application_form)

      qualification_id = application_form.application_qualifications.other.first.id

      qualification_row_value = result.css('.govuk-summary-list__value')[0]
      institution_row_value = result.css('.govuk-summary-list__value')[1]
      year_row_value = result.css('.govuk-summary-list__value')[2]

      expect(qualification_row_value.attr('id')).to include("other-qualifications-#{qualification_id}-qualification")
      expect(institution_row_value.attr('id')).to include("other-qualifications-#{qualification_id}-institution")
      expect(year_row_value.attr('id')).to include("other-qualifications-#{qualification_id}-year")
    end

    it 'renders component with aria-describedby for each attribute row' do
      result = render_inline(described_class, application_form: application_form)

      qualification_id = application_form.application_qualifications.other.first.id

      change_links = [
        result.css('.govuk-summary-list__actions a')[0],
        result.css('.govuk-summary-list__actions a')[1],
        result.css('.govuk-summary-list__actions a')[2],
        result.css('.govuk-summary-list__actions a')[3],
      ]

      change_links.each do |change_link|
        expect(change_link.attr('aria-describedby')).to include(
          "other-qualifications-#{qualification_id}-qualification "\
          "other-qualifications-#{qualification_id}-institution "\
          "other-qualifications-#{qualification_id}-year",
        )
      end
    end
  end

  context 'when other qualifications are not editable' do
    it 'renders component without an edit link' do
      result = render_inline(described_class, application_form: application_form, editable: false)

      expect(result.css('.app-summary-list__actions').text).not_to include('Change')
      expect(result.css('.app-summary-card__actions').text).not_to include(t('application_form.other_qualification.delete'))
    end
  end
end
