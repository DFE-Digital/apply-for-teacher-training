require 'rails_helper'

RSpec.describe CandidateInterface::DegreesReviewComponent do
  let(:application_form) { build_stubbed(:application_form) }
  let(:degree1) do
    build_stubbed(
      :degree_qualification,
      qualification_type: 'BA',
      subject: 'Woof',
      institution_name: 'University of Doge',
      grade: 'Upper second',
      predicted_grade: false,
      start_year: '2005',
      award_year: '2008',
    )
  end
  let(:degree2) do
    build_stubbed(
      :degree_qualification,
      level: 'degree',
      qualification_type: 'BA',
      subject: 'Meow',
      institution_name: 'University of Cate',
      grade: 'First',
      predicted_grade: true,
      start_year: '2007',
      award_year: '2010',
    )
  end

  let(:application_qualifications) { ActiveRecordRelationStub.new(ApplicationQualification, [degree1], scopes: [:degrees]) }

  before do
    allow(application_form).to receive(:application_qualifications).and_return(application_qualifications)
  end

  context 'when degrees are editable' do
    it 'renders component with correct values for a degree type' do
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.css('.govuk-summary-list__key').text).to include(t('application_form.degree.qualification_type.review_label'))
      expect(result.css('.govuk-summary-list__value')[0].text.strip).to eq('BA')
      expect(result.css('.govuk-summary-list__actions a')[0].attr('href')).to include(
        Rails.application.routes.url_helpers.candidate_interface_edit_degree_type_path(degree1),
      )
      expect(result.css('.govuk-summary-list__actions').text).to include(
        "Change #{t('application_form.degree.qualification.change_action')} for BA, Woof, University of Doge, 2008",
      )
    end

    it 'renders component with correct values for a subject' do
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.css('.govuk-summary-list__key').text).to include(t('application_form.degree.subject.review_label'))
      expect(result.css('.govuk-summary-list__value')[1].text.strip).to eq('Woof')
      expect(result.css('.govuk-summary-list__actions a')[1].attr('href')).to include(
        Rails.application.routes.url_helpers.candidate_interface_edit_degree_subject_path(degree1),
      )
      expect(result.css('.govuk-summary-list__actions').text).to include(
        "Change #{t('application_form.degree.qualification.change_action')} for BA, Woof, University of Doge, 2008",
      )
    end

    it 'renders component with correct values for an institution' do
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.css('.govuk-summary-list__key').text).to include(t('application_form.degree.institution_name.review_label'))
      expect(result.css('.govuk-summary-list__value')[2].text.strip).to eq('University of Doge')
      expect(result.css('.govuk-summary-list__actions a')[2].attr('href')).to include(
        Rails.application.routes.url_helpers.candidate_interface_edit_degree_institution_path(degree1),
      )
      expect(result.css('.govuk-summary-list__actions').text).to include(
        "Change #{t('application_form.degree.qualification.change_action')} for BA, Woof, University of Doge, 2008",
      )
    end

    it 'renders component with correct values for an award year' do
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.css('.govuk-summary-list__key').text).to include(t('application_form.degree.award_year.review_label'))
      expect(result.css('.govuk-summary-list__value').text).to include('2005')
      expect(result.css('.govuk-summary-list__value').text).to include('2008')
      expect(result.css('.govuk-summary-list__actions').text).to include(
        "Change #{t('application_form.degree.award_year.change_action')} for BA, Woof, University of Doge, 2008",
      )
    end

    it 'renders component with correct values for a known degree grade' do
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.css('.govuk-summary-list__key').text).to include(t('application_form.degree.grade.review_label'))
      expect(result.css('.govuk-summary-list__value').text).to include('Upper second')
      expect(result.css('.govuk-summary-list__actions').text).to include(
        "Change #{t('application_form.degree.grade.change_action')} for BA, Woof, University of Doge, 2008",
      )
    end

    it 'renders component with correct values for a predicted grade' do
      allow(application_form).to receive(:application_qualifications).and_return(
        ActiveRecordRelationStub.new(ApplicationQualification, [degree1, degree2], scopes: [:degrees]),
      )

      result = render_inline(described_class.new(application_form: application_form))

      expect(result.css('.app-summary-card__title').text).to include('BA Meow')
      expect(result.css('.govuk-summary-list__value').text).to include('First (Predicted)')
    end

    it 'renders component with correct values for an other grade' do
      degree3 = build_stubbed(
        :degree_qualification,
        qualification_type: 'BA',
        subject: 'Hoot',
        institution_name: 'University of Owl',
        grade: 'Third-class honours',
        predicted_grade: false,
        start_year: '2007',
        award_year: '2010',
      )

      allow(application_form).to receive(:application_qualifications).and_return(
        ActiveRecordRelationStub.new(ApplicationQualification, [degree3], scopes: [:degrees]),
      )

      result = render_inline(described_class.new(application_form: application_form))

      expect(result.css('.app-summary-card__title').text).to include('BA (Hons) Hoot')
      expect(result.css('.govuk-summary-list__value').text).to include('Third-class honours')
    end

    it 'renders component with correct values for multiple degrees' do
      allow(application_form).to receive(:application_qualifications).and_return(
        ActiveRecordRelationStub.new(ApplicationQualification, [degree1, degree2], scopes: [:degrees]),
      )

      result = render_inline(described_class.new(application_form: application_form))

      expect(result.css('.app-summary-card__title').text).to include('BA Woof')
      expect(result.css('.app-summary-card__title').text).to include('BA Meow')
    end

    it 'renders component along with a delete link for each degree' do
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.css('.app-summary-card__actions').text.strip).to include(
        "#{t('application_form.degree.delete')} for BA, Woof, University of Doge, 2008",
      )
      expect(result.css('.app-summary-card__actions a')[0].attr('href')).to include(
        Rails.application.routes.url_helpers.candidate_interface_confirm_degree_destroy_path(degree1),
      )
    end
  end

  context 'when degrees are not editable' do
    it 'renders component without an edit link' do
      result = render_inline(described_class.new(application_form: application_form, editable: false))

      expect(result.css('.app-summary-list__actions').text).not_to include('Change')
      expect(result.css('.app-summary-card__actions').text).not_to include(t('application_form.degree.delete'))
    end
  end
end
