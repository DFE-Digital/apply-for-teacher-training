require 'rails_helper'

RSpec.describe OtherQualificationsReviewComponent do
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

  it 'renders component with correct values for a qualification' do
    result = render_inline(OtherQualificationsReviewComponent, application_form: application_form)

    expect(result.css('.app-summary-card__title').text).to include('A-Level Making Doggo Sounds')
    expect(result.css('.govuk-summary-list__key').text).to include(t('application_form.other_qualification.qualification.label'))
    expect(result.css('.govuk-summary-list__value').to_html).to include('A-Level Making Doggo Sounds<br>Doggo Sounds College')
    expect(result.css('.govuk-summary-list__actions a')[0].attr('href')).to include('#')
    expect(result.css('.govuk-summary-list__actions').text).to include("Change #{t('application_form.other_qualification.qualification.change_action')}")
  end

  it 'renders component with correct values for an award year' do
    result = render_inline(OtherQualificationsReviewComponent, application_form: application_form)

    expect(result.css('.app-summary-card__title').text).to include('A-Level Making Doggo Sounds')
    expect(result.css('.govuk-summary-list__key').text).to include(t('application_form.other_qualification.award_year.review_label'))
    expect(result.css('.govuk-summary-list__value').text).to include('2012')
    expect(result.css('.govuk-summary-list__actions').text).to include("Change #{t('application_form.other_qualification.award_year.change_action')}")
  end

  it 'renders component with correct values for a grade' do
    result = render_inline(OtherQualificationsReviewComponent, application_form: application_form)

    expect(result.css('.app-summary-card__title').text).to include('A-Level Making Doggo Sounds')
    expect(result.css('.govuk-summary-list__key').text).to include(t('application_form.other_qualification.grade.label'))
    expect(result.css('.govuk-summary-list__value').text).to include('A')
    expect(result.css('.govuk-summary-list__actions').text).to include("Change #{t('application_form.other_qualification.grade.change_action')}")
  end

  it 'renders component with correct values for multiple qualifications' do
    result = render_inline(OtherQualificationsReviewComponent, application_form: application_form)

    expect(result.css('.app-summary-card__title').text).to include('A-Level Making Doggo Sounds')
    expect(result.css('.app-summary-card__title').text).to include('A-Level Making Cat Sounds')
  end

  it 'renders component along with a delete link for each degree' do
    result = render_inline(OtherQualificationsReviewComponent, application_form: application_form)

    expect(result.css('.app-summary-card__actions').text).to include(t('application_form.other_qualification.delete'))
    expect(result.css('.app-summary-card__actions a')[0].attr('href')).to include('#')
  end
end
