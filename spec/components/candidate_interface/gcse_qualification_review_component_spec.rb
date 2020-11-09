require 'rails_helper'

RSpec.describe CandidateInterface::GcseQualificationReviewComponent do
  context 'with the international_gcses flag on' do
    before do
      FeatureFlag.activate('international_gcses')
    end

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
        naric_reference: '12345',
        comparable_uk_qualification: 'Between GCSE and GCE AS level',
      )
      result = render_inline(
        described_class.new(application_form: application_form, application_qualification: application_qualification, subject: 'maths'),
      )

      expect(result.css('.govuk-summary-list__key')[0].text).to include('Qualification')
      expect(result.css('.govuk-summary-list__value')[0].text).to include('High school diploma')
      expect(result.css('.govuk-summary-list__key')[1].text).to include('Country')
      expect(result.css('.govuk-summary-list__value')[1].text).to include('United States')
      expect(result.css('.govuk-summary-list__key')[2].text).to include('Do you have a UK NARIC statement of comparability?')
      expect(result.css('.govuk-summary-list__value')[2].text).to include('Yes')
      expect(result.css('.govuk-summary-list__key')[3].text).to include('UK NARIC reference number')
      expect(result.css('.govuk-summary-list__value')[3].text).to include('12345')
      expect(result.css('.govuk-summary-list__key')[4].text).to include('Comparable UK qualification')
      expect(result.css('.govuk-summary-list__value')[4].text).to include('Between GCSE and GCE AS level')
      expect(result.css('.govuk-summary-list__key')[5].text).to include('Grade')
      expect(result.css('.govuk-summary-list__value')[5].text).to include('C')
      expect(result.css('.govuk-summary-list__key')[6].text).to include('Year')
      expect(result.css('.govuk-summary-list__value')[6].text).to include('2020')
    end

    it 'displays the naric_statment row and hides the naric_reference and comparable_uk_qualification when nil' do
      application_form = build :application_form
      @qualification = application_qualification = build(
        :application_qualification,
        application_form: application_form,
        qualification_type: 'non_uk',
        non_uk_qualification_type: 'High school diploma',
        level: 'gcse',
        grade: 'c',
        institution_country: 'United States',
        naric_reference: nil,
        comparable_uk_qualification: nil,
      )
      result = render_inline(
        described_class.new(application_form: application_form, application_qualification: application_qualification, subject: 'maths'),
      )

      expect(result.css('.govuk-summary-list__key')[2].text).to include('Do you have a UK NARIC statement of comparability?')
      expect(result.css('.govuk-summary-list__value')[2].text).to include('No')
      expect(result.css('.govuk-summary-list__key').text).not_to include('UK NARIC reference number')
      expect(result.css('.govuk-summary-list__key').text).not_to include('Comparable UK qualification')
    end
  end

  context 'with the international_gcses flag off' do
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

  context 'with the science_gcse_awards flag on' do
    context 'when the candidate has entered a triple science GCSE award' do
      it 'displays each science subject and associated grade' do
        FeatureFlag.activate(:science_gcse_awards)

        application_form = build :application_form
        @qualification = application_qualification = build(
          :application_qualification,
          application_form: application_form,
          qualification_type: 'gcse',
          level: 'gcse',
          grade: nil,
          grades: { physics: 'A', chemistry: 'B', biology: 'C' },
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
  end
end
