require 'rails_helper'

RSpec.describe CandidateInterface::OtherQualificationsReviewComponent do
  let(:application_form) { build_stubbed(:application_form) }
  let(:qualification1) do
    build_stubbed(
      :application_qualification,
      level: 'other',
      qualification_type: 'A-Level',
      subject: 'Making Doggo Sounds',
      grade: 'A',
      predicted_grade: false,
      award_year: '2012',
    )
  end
  let(:qualification2) do
    build_stubbed(
      :application_qualification,
      level: 'other',
      qualification_type: 'A-Level',
      subject: 'Making Cat Sounds',
    )
  end

  context 'when other qualifications are editable' do
    before do
      allow(application_form).to receive(:application_qualifications).and_return(
        ActiveRecordRelationStub.new(ApplicationQualification, [qualification1, qualification2], scopes: [:other]),
      )
    end

    it 'renders component with correct values for a qualification' do
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.css('.app-summary-card__title').text).to include('A-Level Making Doggo Sounds')
      expect(result.css('.govuk-summary-list__key').text).to include(t('application_form.other_qualification.qualification.label'))
      expect(result.css('.govuk-summary-list__value').to_html).to include('A-Level')
      expect(result.css('.govuk-summary-list__value').to_html).to include('Making Doggo Sounds')
      expect(result.css('.govuk-summary-list__actions a')[0].attr('href')).to include(
        Rails.application.routes.url_helpers.candidate_interface_edit_other_qualification_type_path(qualification1),
      )
      expect(result.css('.govuk-summary-list__actions').text).to include(
        "Change #{t('application_form.other_qualification.qualification.change_action')} for A-Level, Making Doggo Sounds, 2012",
      )
    end

    it 'renders component with correct values for an award year' do
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.css('.app-summary-card__title').text).to include('A-Level Making Doggo Sounds')
      expect(result.css('.govuk-summary-list__key').text).to include(t('application_form.other_qualification.award_year.review_label'))
      expect(result.css('.govuk-summary-list__value').text).to include('2012')
      expect(result.css('.govuk-summary-list__actions').text).to include(
        "Change #{t('application_form.other_qualification.award_year.change_action')} for A-Level, Making Doggo Sounds, 2012",
      )
    end

    it 'renders component with correct values for a grade' do
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.css('.app-summary-card__title').text).to include('A-Level Making Doggo Sounds')
      expect(result.css('.govuk-summary-list__key').text).to include(t('application_form.other_qualification.grade.label'))
      expect(result.css('.govuk-summary-list__value').text).to include('A')
      expect(result.css('.govuk-summary-list__actions').text).to include(
        "Change #{t('application_form.other_qualification.grade.change_action')} for A-Level, Making Doggo Sounds, 2012",
      )
    end

    it 'renders component with correct values for multiple qualifications' do
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.css('.app-summary-card__title').text).to include('A-Level Making Doggo Sounds')
      expect(result.css('.app-summary-card__title').text).to include('A-Level Making Cat Sounds')
    end

    it 'renders component along with a delete link for each qualification' do
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.css('.app-summary-card__actions').text.strip).to include(
        "#{t('application_form.other_qualification.delete')} for A-Level, Making Doggo Sounds, 2012",
      )
      expect(result.css('.app-summary-card__actions a')[0].attr('href')).to include(
        Rails.application.routes.url_helpers.candidate_interface_confirm_destroy_other_qualification_path(qualification1),
      )
      expect(result.css('.app-summary-card__actions a')[1].attr('href')).to include(
        Rails.application.routes.url_helpers.candidate_interface_confirm_destroy_other_qualification_path(qualification2),
      )
    end

    context 'Non-UK qualifications' do
      let(:qualification1) do
        build_stubbed(
          :application_qualification,
          level: 'other',
          qualification_type: 'non_uk',
          non_uk_qualification_type: 'Woof',
          subject: 'Making Doggo Sounds',
          institution_country: 'US',
          grade: 'A',
          predicted_grade: false,
          award_year: '2012',
        )
      end

      it 'renders adds optional to the keys for subject and grade rows' do
        result = render_inline(described_class.new(application_form: application_form))

        expect(result.css('.govuk-summary-list__key').text).to include(t('application_form.other_qualification.subject.optional_label'))
        expect(result.css('.govuk-summary-list__key').text).to include(t('application_form.other_qualification.grade.optional_label'))
      end

      it 'renders the correct values for institution_country' do
        result = render_inline(described_class.new(application_form: application_form))

        expect(result.css('.app-summary-card__title').text).to include('Woof Making Doggo Sounds')
        expect(result.css('.govuk-summary-list__key').text).to include(t('application_form.other_qualification.country.label'))
        expect(result.css('.govuk-summary-list__value').text).to include('United States')
        expect(result.css('.govuk-summary-list__actions').text).to include(t('application_form.other_qualification.country.change_action'))
        "Change #{t('application_form.other_qualification.institution_country.change_action')} for Woof, Making Doggo Sounds, United States 2012"
      end
    end

    context 'when a candidate has not provided the subject, grade and year_awarded' do
      let(:qualification1) do
        build_stubbed(
          :application_qualification,
          level: 'other',
          institution_country: nil,
          qualification_type: 'GCSE',
          subject: nil,
          grade: nil,
          award_year: nil,
        )
      end

      it 'renders `Not entered` in the rows value' do
        result = render_inline(described_class.new(application_form: application_form))

        expect(result.css('.govuk-summary-list__value')[0].text).to include('GCSE')
        expect(result.css('.govuk-summary-list__value')[1].text).to include('Not entered')
        expect(result.css('.govuk-summary-list__value')[2].text).to include('Not entered')
        expect(result.css('.govuk-summary-list__value')[3].text).to include('Not entered')
      end
    end
  end

  context 'when other qualifications are not editable' do
    it 'renders component without an edit link' do
      result = render_inline(described_class.new(application_form: application_form, editable: false))

      expect(result.css('.app-summary-list__actions').text).not_to include('Change')
      expect(result.css('.app-summary-card__actions').text).not_to include(t('application_form.other_qualification.delete'))
    end
  end

  describe '#show_missing_banner?' do
    let(:application_form) { create(:application_form) }

    context 'when they have not added an other qualification and are submitting the application' do
      it 'returns false' do
        expect(described_class.new(application_form: application_form, submitting_application: true).show_missing_banner?).to eq false
      end
    end

    context 'when they have fully completed their other qualifications and are submitting their application' do
      it 'returns false' do
        create(:other_qualification, application_form: application_form)
        expect(described_class.new(application_form: application_form, submitting_application: true).show_missing_banner?).to eq false
      end
    end

    context 'when they have an incomplete qualification and are submtting their application' do
      it 'returns true' do
        create(:other_qualification, application_form: application_form, award_year: nil)
        expect(described_class.new(application_form: application_form, submitting_application: true).show_missing_banner?).to eq true
      end
    end
  end
end
