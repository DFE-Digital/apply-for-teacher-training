require 'rails_helper'

RSpec.describe CandidateInterface::DegreesReviewComponent do
  let(:application_form) { build_stubbed(:application_form) }
  let(:degree1) do
    build_stubbed(
      :degree_qualification,
      qualification_type: 'Bachelor of Arts in Architecture',
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
      qualification_type: 'Bachelor of Arts Economics',
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
    context 'when the degree has an abbreviation' do
      it 'renders the correct value on the summary card title' do
        result = render_inline(described_class.new(application_form: application_form))

        expect(result.css('.app-summary-card__title').text).to include('BAArch Woof')
      end
    end

    context 'when the degree does not have an abbreviation' do
      let(:degree1) do
        build_stubbed(
          :degree_qualification,
          level: 'degree',
          qualification_type: 'BSc/Education',
          subject: 'Woof',
          grade: 'First class honours',
        )
      end

      it 'renders the correct value on the summary card title' do
        result = render_inline(described_class.new(application_form: application_form))

        expect(result.css('.app-summary-card__title').text).to include('BSc/Education (Hons) Woof')
      end
    end

    it 'renders component with correct values for a degree type' do
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.css('.govuk-summary-list__key').text).to include(t('application_form.degree.qualification_type.review_label'))
      expect(result.css('.govuk-summary-list__value')[0].text.strip).to eq('Bachelor of Arts in Architecture')
      expect(result.css('.govuk-summary-list__actions a')[0].attr('href')).to include(
        Rails.application.routes.url_helpers.candidate_interface_edit_degree_type_path(degree1),
      )
      expect(result.css('.govuk-summary-list__actions').text).to include(
        "Change #{t('application_form.degree.qualification.change_action')} for Bachelor of Arts in Architecture, Woof, University of Doge, 2008",
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
        "Change #{t('application_form.degree.qualification.change_action')} for Bachelor of Arts in Architecture, Woof, University of Doge, 2008",
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
        "Change #{t('application_form.degree.qualification.change_action')} for Bachelor of Arts in Architecture, Woof, University of Doge, 2008",
      )
    end

    it 'renders component with correct values for an award year' do
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.css('.govuk-summary-list__key').text).to include(t('application_form.degree.award_year.review_label'))
      expect(result.css('.govuk-summary-list__value').text).to include('2005')
      expect(result.css('.govuk-summary-list__value').text).to include('2008')
      expect(result.css('.govuk-summary-list__actions').text).to include(
        "Change #{t('application_form.degree.award_year.change_action')} for Bachelor of Arts in Architecture, Woof, University of Doge, 2008",
      )
    end

    it 'renders component with correct values for a known degree grade' do
      allow(application_form).to receive(:application_qualifications).and_return(
        ActiveRecordRelationStub.new(ApplicationQualification, [degree1, degree2], scopes: [:degrees]),
      )

      result = render_inline(described_class.new(application_form: application_form))

      expect(result.css('.govuk-summary-list__key').text).to include(t('application_form.degree.grade.review_label'))
      expect(result.css('.govuk-summary-list__key').text).to include(t('application_form.degree.grade.review_label_predicted'))
      expect(result.css('.govuk-summary-list__value').text).to include('Upper second')
      expect(result.css('.govuk-summary-list__value').text).to include('First')
      expect(result.css('.govuk-summary-list__actions').text).to include(
        "Change #{t('application_form.degree.grade.change_action')} for Bachelor of Arts in Architecture, Woof, University of Doge, 2008",
      )
    end

    it 'renders component with correct values for the completion status row' do
      allow(application_form).to receive(:application_qualifications).and_return(
        ActiveRecordRelationStub.new(ApplicationQualification, [degree1, degree2], scopes: [:degrees]),
      )

      result = render_inline(described_class.new(application_form: application_form))
      completed_degree_summary = result.css('.app-summary-card').first
      predicted_degree_summary = result.css('.app-summary-card').last

      expect(extract_summary_row(completed_degree_summary, 'Have you completed this degree?').text).to include('Yes')
      expect(extract_summary_row(predicted_degree_summary, 'Have you completed this degree?').text).to include('No')
    end

    def extract_summary_row(element, title)
      element.css('.govuk-summary-list__row').find { |e| e.text.include?(title) }
    end

    it 'renders component with correct values for an other grade' do
      degree3 = build_stubbed(
        :degree_qualification,
        qualification_type: 'Bachelor of Arts in Architecture',
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

      expect(result.css('.app-summary-card__title').text).to include('BAArch (Hons) Hoot')
      expect(result.css('.govuk-summary-list__value').text).to include('Third-class honours')
    end

    it 'renders component with correct values for multiple degrees' do
      allow(application_form).to receive(:application_qualifications).and_return(
        ActiveRecordRelationStub.new(ApplicationQualification, [degree1, degree2], scopes: [:degrees]),
      )

      result = render_inline(described_class.new(application_form: application_form))

      expect(result.css('.app-summary-card__title').text).to include('BAArch Woof')
      expect(result.css('.app-summary-card__title').text).to include('BAEcon Meow')
    end

    it 'renders component along with a delete link for each degree' do
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.css('.app-summary-card__actions').text.strip).to include(
        "#{t('application_form.degree.delete')} for Bachelor of Arts in Architecture, Woof, University of Doge, 2008",
      )
      expect(result.css('.app-summary-card__actions a')[0].attr('href')).to include(
        Rails.application.routes.url_helpers.candidate_interface_confirm_degree_destroy_path(degree1),
      )
    end
  end

  context 'when the degree has been saved without setting the value of predicted_grade' do
    let(:degree1) do
      build_stubbed(
        :degree_qualification,
        qualification_type: 'Bachelor of Arts in Architecture',
        subject: 'Woof',
        institution_name: 'University of Doge',
        grade: 'Upper second',
        predicted_grade: nil,
        start_year: '2005',
        award_year: '2008',
      )
    end

    it 'renders component with correct values for the completion status row' do
      allow(application_form).to receive(:application_qualifications).and_return(
        ActiveRecordRelationStub.new(ApplicationQualification, [degree1], scopes: [:degrees]),
      )

      result = render_inline(described_class.new(application_form: application_form))
      completed_degree_summary = result.css('.app-summary-card').first
      completion_status_row = completed_degree_summary.css('.govuk-summary-list__row').find { |e| e.text.include?('Have you completed this degree?') }

      expect(completion_status_row.css('.govuk-summary-list__value').text).to be_blank
    end
  end

  context 'when degrees are editable and first degree is international' do
    let(:degree1) do
      build_stubbed(
        :degree_qualification,
        qualification_type: 'Bachelor of Arts',
        subject: 'Woof',
        institution_name: 'University of Doge',
        institution_country: 'DE',
        enic_reference: '0123456789',
        comparable_uk_degree: 'bachelor_honours_degree',
        grade: 'erste Klasse',
        predicted_grade: false,
        start_year: '2005',
        award_year: '2008',
        international: true,
      )
    end

    it 'renders component with correct values for an internationl institution' do
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.css('.govuk-summary-list__key').text).to include(t('application_form.degree.institution_name.review_label'))
      expect(result.css('.govuk-summary-list__value')[2].text.strip).to eq('University of Doge, Germany')
      expect(result.css('.govuk-summary-list__actions a')[2].attr('href')).to include(
        Rails.application.routes.url_helpers.candidate_interface_edit_degree_institution_path(degree1),
      )
      expect(result.css('.govuk-summary-list__actions').text).to include(
        "Change #{t('application_form.degree.qualification.change_action')} for Bachelor of Arts, Woof, University of Doge, 2008",
      )
    end

    it 'renders the unabbreviated value on the summary card title' do
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.css('.app-summary-card__title').text).to include('Bachelor of Arts Woof')
    end

    context 'when a UK ENIC reference number has been provided' do
      it 'renders component with correct values for UK ENIC statement' do
        result = render_inline(described_class.new(application_form: application_form))

        expect(result.css('.govuk-summary-list__key').text).to include(t('application_form.degree.institution_name.review_label'))
        expect(result.css('.govuk-summary-list__value')[3].text.strip).to eq('Yes')
        expect(result.css('.govuk-summary-list__actions a')[3].attr('href')).to include(
          Rails.application.routes.url_helpers.candidate_interface_edit_degree_enic_path(degree1),
        )
        expect(result.css('.govuk-summary-list__value')[4].text.strip).to eq('0123456789')
        expect(result.css('.govuk-summary-list__actions a')[4].attr('href')).to include(
          Rails.application.routes.url_helpers.candidate_interface_edit_degree_enic_path(degree1),
        )
        expect(result.css('.govuk-summary-list__value')[5].text.strip).to eq('Bachelor (Honours) degree')
        expect(result.css('.govuk-summary-list__actions a')[5].attr('href')).to include(
          Rails.application.routes.url_helpers.candidate_interface_edit_degree_enic_path(degree1),
        )
        expect(result.css('.govuk-summary-list__actions').text).to include(
          "Change #{t('application_form.degree.qualification.change_action')} for Bachelor of Arts, Woof, University of Doge, 2008",
        )
      end
    end

    context 'when the candidate has not provided a UK ENIC reference number' do
      let(:degree1) do
        build_stubbed(
          :degree_qualification,
          qualification_type: 'BA',
          subject: 'Woof',
          institution_name: 'University of Doge',
          institution_country: 'DE',
          enic_reference: '',
          comparable_uk_degree: nil,
          grade: 'erste Klasse',
          predicted_grade: false,
          start_year: '2005',
          award_year: '2008',
          international: true,
        )
      end

      it 'does not render a row for comparable UK degree and sets UK ENIC reference number to "Not provided"' do
        result = render_inline(described_class.new(application_form: application_form))

        expect(result.css('.govuk-summary-list__key')[3].text).to include(t('application_form.degree.enic_statement.review_label'))
        expect(result.css('.govuk-summary-list__value')[3].text.strip).to eq('No')
        expect(result.css('.govuk-summary-list__key').text).not_to include(t('application_form.degree.enic_reference.review_label'))
        expect(result.css('.govuk-summary-list__key').text).not_to include(t('application_form.degree.comparable_uk_degree.review_label'))
      end
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
