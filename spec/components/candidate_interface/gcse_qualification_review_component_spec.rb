require 'rails_helper'

RSpec.describe CandidateInterface::GcseQualificationReviewComponent do
  context 'a non uk qualification' do
    it 'renders a non-uk GCSE equivalent qualification' do
      application_form = build :application_form
      @qualification = application_qualification = build(
        :application_qualification,
        application_form: application_form,
        qualification_type: 'non_uk',
        non_uk_qualification_type: 'High school diploma',
        level: 'gcse',
        grade: 'C',
        award_year: '2020',
        institution_country: 'US',
        enic_reference: '12345',
        comparable_uk_qualification: 'Between GCSE and GCE AS level',
      )
      result = render_inline(
        described_class.new(application_form: application_form, application_qualification: application_qualification, subject: 'maths'),
      )

      expect(result.css('.govuk-summary-list__key')[0].text).to include('Qualification')
      expect(result.css('.govuk-summary-list__value')[0].text).to include('High school diploma')
      expect(result.css('.govuk-summary-list__key')[1].text).to include('Country')
      expect(result.css('.govuk-summary-list__value')[1].text).to include('United States')
      expect(result.css('.govuk-summary-list__key')[2].text).to include('Do you have a UK ENIC statement of comparability?')
      expect(result.css('.govuk-summary-list__value')[2].text).to include('Yes')
      expect(result.css('.govuk-summary-list__key')[3].text).to include('UK ENIC reference number')
      expect(result.css('.govuk-summary-list__value')[3].text).to include('12345')
      expect(result.css('.govuk-summary-list__key')[4].text).to include('Comparable UK qualification')
      expect(result.css('.govuk-summary-list__value')[4].text).to include('Between GCSE and GCE AS level')
      expect(result.css('.govuk-summary-list__key')[5].text).to include('Grade')
      expect(result.css('.govuk-summary-list__value')[5].text).to include('C')
      expect(result.css('.govuk-summary-list__key')[6].text).to include('Year')
      expect(result.css('.govuk-summary-list__value')[6].text).to include('2020')
    end

    it 'displays the enic_statment row and hides the enic_reference and comparable_uk_qualification when nil' do
      application_form = build :application_form
      @qualification = application_qualification = build(
        :application_qualification,
        application_form: application_form,
        qualification_type: 'non_uk',
        non_uk_qualification_type: 'High school diploma',
        level: 'gcse',
        grade: 'c',
        institution_country: 'United States',
        enic_reference: nil,
        comparable_uk_qualification: nil,
      )
      result = render_inline(
        described_class.new(application_form: application_form, application_qualification: application_qualification, subject: 'maths'),
      )

      expect(result.css('.govuk-summary-list__key')[2].text).to include('Do you have a UK ENIC statement of comparability?')
      expect(result.css('.govuk-summary-list__value')[2].text).to include('No')
      expect(result.css('.govuk-summary-list__key').text).not_to include('UK ENIC reference number')
      expect(result.css('.govuk-summary-list__key').text).not_to include('Comparable UK qualification')
    end
  end

  context 'a uk qualification' do
    it 'displays award year, qualification type and grade' do
      application_form = build :application_form
      @qualification = application_qualification = build(
        :application_qualification,
        application_form: application_form,
        qualification_type: 'GCSE',
        level: 'gcse',
        grade: 'c',
        institution_country: 'US',
      )
      result = render_inline(
        described_class.new(application_form: application_form, application_qualification: application_qualification, subject: 'maths'),
      )

      expect(result.text).to match(/Qualification\s+GCSE/)
      expect(result.text).to match(/Year awarded\s+#{@qualification.award_year}/)
      expect(result.text).to match(/Grade\s+#{@qualification.grade}/)
      expect(result.text).not_to match(/Country\s+#{@qualification.institution_country}/)
    end
  end

  context 'when the candidate has entered a triple science GCSE award' do
    it 'displays each science subject and associated grade' do
      application_form = build :application_form
      @qualification = application_qualification = build(
        :application_qualification,
        application_form: application_form,
        qualification_type: 'gcse',
        level: 'gcse',
        grade: nil,
        constituent_grades: { physics: { grade: 'A' }, chemistry: { grade: 'B' }, biology: { grade: 'C' } },
        subject: ApplicationQualification::SCIENCE_TRIPLE_AWARD,
      )

      result = render_inline(
        described_class.new(
          application_form: application_form,
          application_qualification: application_qualification,
          subject: 'science',
        ),
      )

      expect(result.css('.govuk-summary-list__key')[1].text).to include('Grade')
      expect(result.css('.govuk-summary-list__value')[1].text).to include('C (Biology)B (Chemistry)A (Physics)')
    end
  end

  context 'when the candidate has entered their English GCSE grades' do
    it 'displays each English GCSE and associated grade' do
      application_form = build :application_form
      @qualification = application_qualification = build(
        :application_qualification,
        application_form: application_form,
        qualification_type: 'gcse',
        level: 'gcse',
        grade: nil,
        constituent_grades: { english: { grade: 'E' }, english_literature: { grade: 'D' }, 'Cockney Rhyming Slang': { grade: 'A*' } },
        subject: 'english',
      )

      result = render_inline(
        described_class.new(
          application_form: application_form,
          application_qualification: application_qualification,
          subject: 'english',
        ),
      )

      expect(result.css('.govuk-summary-list__key')[1].text).to include('Grade')
      expect(result.css('.govuk-summary-list__value')[1].text).to include('E (English)D (English Literature)A* (Cockney Rhyming Slang)')
    end
  end

  describe '#show_values_missing_banner?' do
    context 'when they have an incomplete qualification and are submitting their application' do
      it 'returns true' do
        application_form = create(:application_form, maths_gcse_completed: true)

        application_qualification = create(
          :application_qualification,
          application_form: application_form,
          qualification_type: 'gcse',
          level: 'gcse',
          grade: nil,
          award_year: nil,
          subject: 'maths',
        )
        result = described_class.new(
          application_form: application_form,
          application_qualification: application_qualification,
          subject: 'maths',
          submitting_application: true,
        )

        expect(result.show_values_missing_banner?).to eq true
      end
    end
  end
end
