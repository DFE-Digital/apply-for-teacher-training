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
        grade: 'c',
        institution_country: 'US',
        naric_reference: '12345',
        comparable_uk_qualification: 'Between GCSE and GCE AS level',
      )
      result = render_inline(
        described_class.new(application_form: application_form, application_qualification: application_qualification, subject: 'maths'),
      )

      expect(result.text).to match(/Qualification\s+#{@qualification.non_uk_qualification_type}/)
      expect(result.text).to match(/Year awarded\s+#{@qualification.award_year}/)
      expect(result.text).to match(/Grade\s+#{@qualification.grade}/)
      expect(result.text).to match(/Country\s+#{COUNTRIES[@qualification.institution_country]}/)
    end

    it 'displays "Not provided" for naric_reference and comparable_uk_qualification when nil' do
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

      expect(result.text).to match(/NARIC reference number\s+Not provided/)
      expect(result.text).to match(/Comparable UK qualification\s+Not provided/)
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
end
