require 'rails_helper'

RSpec.describe CandidateInterface::GcseInternationalEquivalentReviewComponent,
               feature_flag: '2027_international_qualifications_flow' do
  include Rails.application.routes.url_helpers

  context 'a non uk qualification' do
    it 'renders the correct rows when no information beyond non_uk' do
      application_form = build(:application_form)
      application_qualification = build(
        :application_qualification,
        application_form:,
        qualification_type: 'non_uk',
        non_uk_qualification_type: nil,
        level: 'gcse',
        subject: 'maths',
        grade: nil,
        award_year: nil,
        institution_country: nil,
        enic_reference: nil,
        comparable_uk_qualification: nil,
        enic_reason: nil,
      )
      result = render_inline(
        described_class.new(application_form:, application_qualification:, subject: 'maths'),
      )

      expect(result.css('.govuk-summary-list__key')[0].text).to include('Type of qualification')
      expect(result.css('.govuk-summary-list__value')[0].text).to include('Qualification from outside the UK')
      expect(result.css('.govuk-summary-list__key')[1].text).to include('Country or territory')
      expect(result.css('.govuk-summary-list__value')[1].text).to include('Enter the country or territory where you studied for your maths qualification')
      expect(result.css('.govuk-summary-list__key')[2].text).to include('Qualification')
      expect(result.css('.govuk-summary-list__value')[2].text).to include('Enter your qualification')

      expect(result.css('.govuk-summary-list__key').text).not_to include('Grade')
      expect(result.css('.govuk-summary-list__value').text).not_to include('Enter your grade')
      expect(result.css('.govuk-summary-list__key').text).not_to include('Do you have a UK ENIC statement of comparability?')
      expect(result.css('.govuk-summary-list__value').text).not_to include('Enter your ENIC status')
      expect(result.css('.govuk-summary-list__key').text).not_to include('Year awarded')
      expect(result.css('.govuk-summary-list__value').text).not_to include('Enter the year the qualification was awarded')
    end

    it 'renders the correct rows when only country' do
      application_form = build(:application_form)
      application_qualification = build(
        :application_qualification,
        application_form:,
        qualification_type: 'non_uk',
        non_uk_qualification_type: nil,
        level: 'gcse',
        subject: 'maths',
        grade: nil,
        award_year: nil,
        institution_country: 'GH',
        enic_reference: nil,
        comparable_uk_qualification: nil,
        enic_reason: nil,
      )
      result = render_inline(
        described_class.new(application_form:, application_qualification:, subject: 'maths'),
      )

      expect(result.css('.govuk-summary-list__key')[0].text).to include('Type of qualification')
      expect(result.css('.govuk-summary-list__value')[0].text).to include('Qualification from outside the UK')
      expect(result.css('.govuk-summary-list__key')[1].text).to include('Country or territory')
      expect(result.css('.govuk-summary-list__value')[1].text).to include('Ghana')
      expect(result.css('.govuk-summary-list__key')[2].text).to include('Qualification')
      expect(result.css('.govuk-summary-list__value')[2].text).to include('Enter your qualification')

      expect(result.css('.govuk-summary-list__key').text).not_to include('Grade')
      expect(result.css('.govuk-summary-list__value').text).not_to include('Enter your grade')
      expect(result.css('.govuk-summary-list__key').text).not_to include('Do you have a UK ENIC statement of comparability?')
      expect(result.css('.govuk-summary-list__value').text).not_to include('Enter your ENIC status')
      expect(result.css('.govuk-summary-list__key').text).not_to include('Year awarded')
      expect(result.css('.govuk-summary-list__value').text).not_to include('Enter the year the qualification was awarded')
    end

    it 'renders the correct rows when only country and qualification' do
      application_form = build(:application_form)
      application_qualification = build(
        :application_qualification,
        application_form:,
        qualification_type: 'non_uk',
        non_uk_qualification_type: 'WASSCE (West African Senior School Certificate Examination)',
        level: 'gcse',
        subject: 'maths',
        grade: nil,
        award_year: nil,
        institution_country: 'GH',
        enic_reference: nil,
        comparable_uk_qualification: nil,
        enic_reason: nil,
      )
      result = render_inline(
        described_class.new(application_form:, application_qualification:, subject: 'maths'),
      )

      expect(result.css('.govuk-summary-list__key')[0].text).to include('Type of qualification')
      expect(result.css('.govuk-summary-list__value')[0].text).to include('Qualification from outside the UK')
      expect(result.css('.govuk-summary-list__key')[1].text).to include('Country or territory')
      expect(result.css('.govuk-summary-list__value')[1].text).to include('Ghana')
      expect(result.css('.govuk-summary-list__key')[2].text).to include('Qualification')
      expect(result.css('.govuk-summary-list__value')[2].text).to include('WASSCE (West African Senior School Certificate Examination)')
      expect(result.css('.govuk-summary-list__key')[3].text).to include('Grade')
      expect(result.css('.govuk-summary-list__value')[3].text).to include('Enter your grade')

      expect(result.css('.govuk-summary-list__key').text).not_to include('Do you have a UK ENIC statement of comparability?')
      expect(result.css('.govuk-summary-list__value').text).not_to include('Enter your ENIC status')
      expect(result.css('.govuk-summary-list__key').text).not_to include('Year awarded')
      expect(result.css('.govuk-summary-list__value').text).not_to include('Enter the year the qualification was awarded')
    end

    it 'renders the correct rows when a structured passing grade is entered' do
      application_form = build(:application_form)
      application_qualification = build(
        :application_qualification,
        application_form:,
        qualification_type: 'non_uk',
        non_uk_qualification_type: 'WASSCE (West African Senior School Certificate Examination)',
        level: 'gcse',
        subject: 'maths',
        grade: 'B2',
        award_year: nil,
        institution_country: 'GH',
        enic_reference: nil,
        comparable_uk_qualification: nil,
        enic_reason: nil,
      )
      result = render_inline(
        described_class.new(application_form:, application_qualification:, subject: 'maths'),
      )

      expect(result.css('.govuk-summary-list__key')[0].text).to include('Type of qualification')
      expect(result.css('.govuk-summary-list__value')[0].text).to include('Qualification from outside the UK')
      expect(result.css('.govuk-summary-list__key')[1].text).to include('Country or territory')
      expect(result.css('.govuk-summary-list__value')[1].text).to include('Ghana')
      expect(result.css('.govuk-summary-list__key')[2].text).to include('Qualification')
      expect(result.css('.govuk-summary-list__value')[2].text).to include('WASSCE (West African Senior School Certificate Examination)')
      expect(result.css('.govuk-summary-list__key')[3].text).to include('Grade')
      expect(result.css('.govuk-summary-list__value')[3].text).to include('B2')
      expect(result.css('.govuk-summary-list__key')[4].text).to include('Do you have a UK ENIC statement of comparability?')
      expect(result.css('.govuk-summary-list__value')[4]).to have_link('Enter your ENIC status', href: candidate_interface_gcse_new_international_flow_edit_enic_path(subject: 'maths', 'return-to': 'application-review'))
      expect(result.css('.govuk-summary-list__key')[5].text).to include('Year awarded')
      expect(result.css('.govuk-summary-list__value')[5].text).to include('Enter the year the qualification was awarded')

      expect(result.css('.govuk-summary-list__key').text).not_to include('Evidence that your maths skills are at GCSE grade 4 (C) or above')
      expect(result.css('.govuk-summary-list__value').text).not_to include('Enter evidence that your maths skills are at GCSE grade 4 (C) or above')
    end

    it 'renders the correct rows when a structured failing grade is entered' do
      application_form = build(:application_form)
      application_qualification = build(
        :application_qualification,
        application_form:,
        qualification_type: 'non_uk',
        non_uk_qualification_type: 'WASSCE (West African Senior School Certificate Examination)',
        level: 'gcse',
        subject: 'maths',
        grade: 'D7',
        award_year: nil,
        institution_country: 'GH',
        enic_reference: nil,
        comparable_uk_qualification: nil,
        enic_reason: nil,
      )
      result = render_inline(
        described_class.new(application_form:, application_qualification:, subject: 'maths'),
      )

      expect(result.css('.govuk-summary-list__key')[0].text).to include('Type of qualification')
      expect(result.css('.govuk-summary-list__value')[0].text).to include('Qualification from outside the UK')
      expect(result.css('.govuk-summary-list__key')[1].text).to include('Country or territory')
      expect(result.css('.govuk-summary-list__value')[1].text).to include('Ghana')
      expect(result.css('.govuk-summary-list__key')[2].text).to include('Qualification')
      expect(result.css('.govuk-summary-list__value')[2].text).to include('WASSCE (West African Senior School Certificate Examination)')
      expect(result.css('.govuk-summary-list__key')[3].text).to include('Grade')
      expect(result.css('.govuk-summary-list__value')[3].text).to include('D7')
      expect(result.css('.govuk-summary-list__key')[4].text).to include('Do you have a UK ENIC statement of comparability?')
      expect(result.css('.govuk-summary-list__value')[4]).to have_link('Enter your ENIC status', href: candidate_interface_gcse_new_international_flow_interruption_path(subject: 'maths', 'return-to': 'application-review'))
      expect(result.css('.govuk-summary-list__key')[5].text).to include('Evidence that your maths skills are at GCSE grade 4 (C) or above')
      expect(result.css('.govuk-summary-list__value')[5]).to have_link('Enter evidence that your maths skills are at GCSE grade 4 (C) or above', href: candidate_interface_gcse_new_international_flow_interruption_path(subject: 'maths', 'return-to': 'application-review'))
      expect(result.css('.govuk-summary-list__key')[6].text).to include('Year awarded')
      expect(result.css('.govuk-summary-list__value')[6].text).to include('Enter the year the qualification was awarded')
    end

    it 'renders the correct rows when a non-structured grade is entered' do
      application_form = build(:application_form)
      application_qualification = build(
        :application_qualification,
        application_form:,
        qualification_type: 'non_uk',
        non_uk_qualification_type: 'WASSCE (West African Senior School Certificate Examination)',
        level: 'gcse',
        subject: 'maths',
        grade: '99%',
        award_year: nil,
        institution_country: 'GH',
        enic_reference: nil,
        comparable_uk_qualification: nil,
        enic_reason: nil,
      )
      result = render_inline(
        described_class.new(application_form:, application_qualification:, subject: 'maths'),
      )

      expect(result.css('.govuk-summary-list__key')[0].text).to include('Type of qualification')
      expect(result.css('.govuk-summary-list__value')[0].text).to include('Qualification from outside the UK')
      expect(result.css('.govuk-summary-list__key')[1].text).to include('Country or territory')
      expect(result.css('.govuk-summary-list__value')[1].text).to include('Ghana')
      expect(result.css('.govuk-summary-list__key')[2].text).to include('Qualification')
      expect(result.css('.govuk-summary-list__value')[2].text).to include('WASSCE (West African Senior School Certificate Examination)')
      expect(result.css('.govuk-summary-list__key')[3].text).to include('Grade')
      expect(result.css('.govuk-summary-list__value')[3].text).to include('99%')
      expect(result.css('.govuk-summary-list__key')[4].text).to include('Do you have a UK ENIC statement of comparability?')
      expect(result.css('.govuk-summary-list__value')[4]).to have_link('Enter your ENIC status', href: candidate_interface_gcse_new_international_flow_edit_enic_path(subject: 'maths', 'return-to': 'application-review'))
      expect(result.css('.govuk-summary-list__key')[5].text).to include('Year awarded')
      expect(result.css('.govuk-summary-list__value')[5].text).to include('Enter the year the qualification was awarded')

      expect(result.css('.govuk-summary-list__key').text).not_to include('Evidence that your maths skills are at GCSE grade 4 (C) or above')
      expect(result.css('.govuk-summary-list__value').text).not_to include('Enter evidence that your maths skills are at GCSE grade 4 (C) or above')
    end

    it 'displays the enic_statement row and hides the enic_reference and comparable_uk_qualification when nil' do
      application_form = build(:application_form)
      application_qualification = build(
        :application_qualification,
        application_form:,
        qualification_type: 'non_uk',
        non_uk_qualification_type: 'WASSCE',
        level: 'gcse',
        subject: 'maths',
        grade: 'D7',
        institution_country: 'Ghana',
        enic_reference: nil,
        enic_reason: nil,
        comparable_uk_qualification: nil,
      )
      result = render_inline(
        described_class.new(application_form:, application_qualification:, subject: 'maths'),
      )

      expect(result.css('.govuk-summary-list__key')[4].text).to include('Do you have a UK ENIC statement of comparability?')
      expect(result).to have_link('Enter your ENIC status')
      expect(result.css('.govuk-summary-list__key').text).not_to include('UK ENIC reference number')
      expect(result.css('.govuk-summary-list__key').text).not_to include('Comparable UK qualification')
    end

    (ApplicationQualification.enic_reasons.keys - ['obtained']).each do |reason|
      it "hides the enic_reference row when enic_reason is not 'obtained'" do
        application_form = build(:application_form)
        application_qualification = build(
          :application_qualification,
          application_form:,
          qualification_type: 'non_uk',
          non_uk_qualification_type: 'KCSE',
          level: 'gcse',
          subject: 'maths',
          grade: 'D7',
          institution_country: 'Kenya',
          enic_reference: nil,
          enic_reason: reason,
          comparable_uk_qualification: nil,
        )

        result = render_inline(described_class.new(application_form:, application_qualification:, subject: 'maths'))

        expect(result.css('.govuk-summary-list__key').text).not_to include('UK ENIC reference number')
      end
    end

    it 'displays the enic_statement row and shows the enic_reference when obtained' do
      application_form = build(:application_form)
      application_qualification = build(
        :application_qualification,
        application_form:,
        qualification_type: 'non_uk',
        non_uk_qualification_type: 'KCSE',
        level: 'gcse',
        subject: 'english',
        grade: 'D7',
        institution_country: 'Kenya',
        enic_reference: nil,
        enic_reason: 'obtained',
        comparable_uk_qualification: nil,
      )
      result = render_inline(
        described_class.new(application_form:, application_qualification:, subject: 'maths'),
      )

      expect(result.css('.govuk-summary-list__key')[4].text).to include('Do you have a UK ENIC statement of comparability?')
      expect(result.css('.govuk-summary-list__value')[4].text).to include('Yes, I have a statement of comparability')
      expect(result.css('.govuk-summary-list__key')[5].text).to include('UK ENIC reference number')
    end

    it 'displays the evidence row and no enic rows when evidence is provided' do
      application_form = build(:application_form)
      application_qualification = build(
        :application_qualification,
        application_form:,
        qualification_type: 'non_uk',
        non_uk_qualification_type: 'KCSE (Kenya Certificate of Secondary Education)',
        level: 'gcse',
        subject: 'english',
        grade: 'D',
        institution_country: 'KE',
        enic_reference: nil,
        enic_reason: nil,
        comparable_uk_qualification: nil,
        not_completed_explanation: 'I do not have the required evidence',
      )

      result = render_inline(
        described_class.new(application_form:, application_qualification:, subject: 'maths'),
      )

      expect(result.css('.govuk-summary-list__key')[4].text).to include('Evidence that your maths skills are at GCSE grade 4 (C) or above')
      expect(result.css('.govuk-summary-list__value')[4].text).to include('I do not have the required evidence')
      expect(result.css('.govuk-summary-list__key').text).not_to include('Do you have a UK ENIC statement of comparability?')
      expect(result.css('.govuk-summary-list__key').text).not_to include('UK ENIC reference number')
    end
  end
end
