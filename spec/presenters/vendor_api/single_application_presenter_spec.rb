require 'rails_helper'

# To avoid this test becoming too large, only use this spec to test complex
# logic in the presenter. For anything that is passed straight from the database
# to the API, make sure that spec/system/vendor_api/vendor_receives_application_spec.rb is updated.
RSpec.describe VendorAPI::SingleApplicationPresenter do
  include VendorAPISpecHelpers

  describe 'attributes.withdrawal' do
    it 'returns a withdrawal object' do
      withdrawn_at = Time.zone.local(2019, 1, 1, 0, 0, 0)
      application_form = create(:application_form,
                                :minimum_info)
      application_choice = create(:application_choice, status: 'withdrawn', application_form: application_form, withdrawn_at: withdrawn_at)

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.to_json).to be_valid_against_openapi_schema('Application')
      expect(response[:attributes][:withdrawal]).to eq(reason: nil, date: withdrawn_at.iso8601)
    end
  end

  describe 'attributes.rejection' do
    it 'returns a rejection object' do
      rejected_at = Time.zone.local(2019, 1, 1, 0, 0, 0)
      application_form = create(:application_form,
                                :minimum_info)
      application_choice = create(:application_choice, status: 'rejected', application_form: application_form, rejected_at: rejected_at, rejection_reason: 'Course full')

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.to_json).to be_valid_against_openapi_schema('Application')
      expect(response[:attributes][:rejection]).to eq(reason: 'Course full', date: rejected_at.iso8601)
    end
  end

  describe 'attributes.rejection with a withdrawn offer' do
    it 'returns a rejection object' do
      withdrawn_at = Time.zone.local(2019, 1, 1, 0, 0, 0)
      application_form = create(:application_form,
                                :minimum_info)
      application_choice = create(:application_choice, status: 'rejected', application_form: application_form, offer_withdrawn_at: withdrawn_at, offer_withdrawal_reason: 'Course full')

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.to_json).to be_valid_against_openapi_schema('Application')
      expect(response[:attributes][:rejection]).to eq(reason: 'Course full', date: withdrawn_at.iso8601)
    end
  end

  describe 'attributes.rejection with a rejected application with no feedback' do
    it 'returns a rejection object' do
      rejected_at = Time.zone.local(2019, 1, 1, 0, 0, 0)
      application_form = create(:application_form,
                                :minimum_info)
      application_choice = create(:application_choice, :with_rejection_by_default, application_form: application_form, rejected_at: rejected_at)

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.to_json).to be_valid_against_openapi_schema('Application')
      expect(response[:attributes][:rejection]).to eq(reason: 'Not entered', date: rejected_at.iso8601)
    end
  end

  describe 'attributes.hesa_itt_data' do
    let(:disabilities) { %w[Deaf] }
    let(:hesa_disabilities) { %w[57] }
    let(:ethnic_group) { 'White' }
    let(:ethnic_background) { 'Irish' }
    let(:equality_and_diversity) do
      {
        ethnic_group: ethnic_group,
        ethnic_background: ethnic_background,
        disabilities: disabilities,
        hesa_disabilities: hesa_disabilities,
        hesa_sex: '1',
      }
    end
    let(:application_choice) do
      application_form = create(:application_form,
                                :minimum_info,
                                equality_and_diversity: equality_and_diversity)
      create(:application_choice, :with_accepted_offer, application_form: application_form)
    end

    context 'when an application choice has had an accepted offer' do
      it 'returns the hesa_itt_data attribute of an application' do
        equality_and_diversity_data = application_choice.application_form.equality_and_diversity

        response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

        expect(response.dig(:attributes, :hesa_itt_data)).to eq(
          disability: equality_and_diversity_data['hesa_disabilities'],
          ethnicity: equality_and_diversity_data['hesa_ethnicity'],
          sex: equality_and_diversity_data['hesa_sex'],
          other_disability_details: nil,
          other_ethnicity_details: nil,
        )
      end
    end

    context 'when the application choice has other disabilities' do
      let(:disabilities) { ['Deaf', 'A very specific thing'] }
      let(:hesa_disabilities) { %w[57 96] }

      it 'returns the other disability in the other_disability_details field' do
        equality_and_diversity_data = application_choice.application_form.equality_and_diversity

        response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

        expect(response.dig(:attributes, :hesa_itt_data)).to eq(
          disability: equality_and_diversity_data['hesa_disabilities'],
          ethnicity: equality_and_diversity_data['hesa_ethnicity'],
          sex: equality_and_diversity_data['hesa_sex'],
          other_disability_details: 'A very specific thing',
          other_ethnicity_details: nil,
        )
      end
    end

    context 'when the application choice has no disabilities or ethnicities' do
      let(:equality_and_diversity) { {} }

      it 'returns no the disability or ethnicity details' do
        equality_and_diversity_data = application_choice.application_form.equality_and_diversity

        response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

        expect(response.dig(:attributes, :hesa_itt_data)).to eq(
          disability: equality_and_diversity_data['hesa_disabilities'],
          ethnicity: equality_and_diversity_data['hesa_ethnicity'],
          sex: equality_and_diversity_data['hesa_sex'],
          other_disability_details: nil,
          other_ethnicity_details: nil,
        )
      end
    end

    context 'when the application choice has other freetext ethnicity' do
      let(:ethnic_group) { 'White' }
      let(:ethnic_background) { 'Custom ethnic background' }

      it 'returns the other ethnicity in the other_ethnicity_details field' do
        equality_and_diversity_data = application_choice.application_form.equality_and_diversity

        response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

        expect(response.dig(:attributes, :hesa_itt_data)).to eq(
          disability: equality_and_diversity_data['hesa_disabilities'],
          ethnicity: equality_and_diversity_data['hesa_ethnicity'],
          sex: equality_and_diversity_data['hesa_sex'],
          other_disability_details: nil,
          other_ethnicity_details: 'Custom ethnic background',
        )
      end
    end

    context 'when the application choice has other non-freetext ethnicity' do
      let(:ethnic_group) { 'Another ethnic group' }
      let(:ethnic_background) { 'Another ethnic background' }

      it 'does not return the other ethnicity in the other_ethnicity_details field' do
        equality_and_diversity_data = application_choice.application_form.equality_and_diversity

        response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

        expect(response.dig(:attributes, :hesa_itt_data)).to eq(
          disability: equality_and_diversity_data['hesa_disabilities'],
          ethnicity: equality_and_diversity_data['hesa_ethnicity'],
          sex: equality_and_diversity_data['hesa_sex'],
          other_disability_details: nil,
          other_ethnicity_details: nil,
        )
      end
    end

    context 'when the application choice has set prefer not to say as the ethnic background' do
      let(:ethnic_group) { 'Another ethnic group' }
      let(:ethnic_background) { 'Prefer not to say' }

      it 'does not return the other ethnicity in the other_ethnicity_details field' do
        equality_and_diversity_data = application_choice.application_form.equality_and_diversity

        response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

        expect(response.dig(:attributes, :hesa_itt_data)).to eq(
          disability: equality_and_diversity_data['hesa_disabilities'],
          ethnicity: equality_and_diversity_data['hesa_ethnicity'],
          sex: equality_and_diversity_data['hesa_sex'],
          other_disability_details: nil,
          other_ethnicity_details: nil,
        )
      end
    end

    context 'when an application choice has not had an accepted offer' do
      let(:application_choice) do
        application_form = create(:application_form,
                                  :minimum_info,
                                  :with_equality_and_diversity_data)
        create(:application_choice, :with_offer, application_form: application_form)
      end

      it 'the hesa_itt_data attribute of an application is nil' do
        response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

        expect(response[:attributes][:hesa_itt_data]).to be_nil
      end
    end
  end

  describe 'attributes.work_history_break_explanation' do
    let(:february2019) { Time.zone.local(2019, 2, 1) }
    let(:april2019) { Time.zone.local(2019, 4, 1) }
    let(:september2019) { Time.zone.local(2019, 9, 1) }
    let(:december2019) { Time.zone.local(2019, 12, 1) }

    context 'when the work history breaks field has a value' do
      it 'returns the work_history_breaks attribute of an application' do
        breaks = []
        application_form = build_stubbed(
          :application_form,
          :with_completed_references,
          work_history_breaks: 'I was sleeping.',
          application_work_history_breaks: breaks,
        )
        application_choice = build_stubbed(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)

        response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

        expect(response.to_json).to be_valid_against_openapi_schema('Application')
        expect(response[:attributes][:work_experience][:work_history_break_explanation]).to eq('I was sleeping.')
      end
    end

    context 'when individual breaks have been entered' do
      it 'returns a concatentation of application_work_history_breaks of an application' do
        break1 = build_stubbed(:application_work_history_break, start_date: february2019, end_date: april2019, reason: 'I was watching TV.')
        break2 = build_stubbed(:application_work_history_break, start_date: september2019, end_date: december2019, reason: 'I was playing games.')
        breaks = [break1, break2]
        application_form = build_stubbed(
          :application_form,
          :with_completed_references,
          work_history_breaks: nil,
          application_work_history_breaks: breaks,
        )
        application_choice = build_stubbed(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)

        response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

        expect(response.to_json).to be_valid_against_openapi_schema('Application')
        expect(response[:attributes][:work_experience][:work_history_break_explanation]).to eq(
          "February 2019 to April 2019: I was watching TV.\n\nSeptember 2019 to December 2019: I was playing games.",
        )
      end
    end

    context 'when no breaks have been entered' do
      it 'returns an empty string' do
        breaks = []
        application_form = build_stubbed(
          :application_form,
          :with_completed_references,
          work_history_breaks: nil,
          application_work_history_breaks: breaks,
        )
        application_choice = build_stubbed(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)

        response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

        expect(response.to_json).to be_valid_against_openapi_schema('Application')
        expect(response[:attributes][:work_experience][:work_history_break_explanation]).to eq('')
      end
    end
  end

  describe 'attributes.candidate.nationality' do
    it 'compacts two nationalities with the same ISO value' do
      application_form = create(:application_form,
                                :minimum_info,
                                first_nationality: 'Welsh',
                                second_nationality: 'Scottish')
      application_choice = create(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.dig(:attributes, :candidate, :nationality)).to eq %w[GB]
    end

    it 'returns nationality in the correct format' do
      application_form = create(:application_form,
                                :minimum_info,
                                first_nationality: 'British',
                                second_nationality: 'American')
      application_choice = create(:application_choice, :awaiting_provider_decision, application_form: application_form)

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.to_json).to be_valid_against_openapi_schema('Application')
      expect(response[:attributes][:candidate][:nationality]).to eq(%w[GB US])
    end

    it 'returns sorted array of nationalties so British or Irish are first' do
      application_form = create(:application_form,
                                :minimum_info,
                                first_nationality: 'Canadian',
                                second_nationality: 'Spanish',
                                third_nationality: 'Irish',
                                fourth_nationality: 'Welsh')
      application_choice = create(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.dig(:attributes, :candidate, :nationality)).to eq(%w[GB IE CA ES])
    end
  end

  describe 'attributes.candidate.domicile' do
    it 'uses DomicileResolver to return a HESA code' do
      application_form = create(:application_form, :minimum_info)
      application_choice = create(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.dig(:attributes, :candidate, :domicile)).to eq(application_form.domicile)
    end
  end

  describe 'attributes.candidate.uk_residency_status' do
    it 'returns UK Citizen if the candidates nationalties include UK' do
      application_form = create(:application_form,
                                :minimum_info,
                                first_nationality: 'Irish',
                                second_nationality: 'British')
      application_choice = create(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.dig(:attributes, :candidate, :uk_residency_status)).to eq('UK Citizen')
    end

    it 'returns Irish Citizen if the candidates nationalties is Irish' do
      application_form = create(:application_form,
                                :minimum_info,
                                first_nationality: 'Canadian',
                                second_nationality: 'Irish')
      application_choice = create(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.dig(:attributes, :candidate, :uk_residency_status)).to eq('Irish Citizen')
    end

    it 'returns details of the immigration status if the candidates answered the have the right to work/study in the UK' do
      application_form = create(:application_form,
                                :minimum_info,
                                first_nationality: 'Canadian',
                                right_to_work_or_study: 'yes',
                                right_to_work_or_study_details: 'I have Settled status')
      application_choice = create(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.dig(:attributes, :candidate, :uk_residency_status)).to eq('I have Settled status')
    end

    it 'returns correct message if the candidates answered they do not yet have the right to work/study in the UK' do
      application_form = create(:application_form,
                                :minimum_info,
                                first_nationality: 'Canadian',
                                right_to_work_or_study: 'no')
      application_choice = create(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.dig(:attributes, :candidate, :uk_residency_status)).to eq('Candidate needs to apply for permission to work and study in the UK')
    end

    it 'returns correct message if the candidate has answered they do not know if they have the right to work/study in the UK' do
      application_form = create(:application_form,
                                :minimum_info,
                                first_nationality: 'Canadian',
                                right_to_work_or_study: 'decide_later')
      application_choice = create(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.dig(:attributes, :candidate, :uk_residency_status)).to eq('Candidate needs to apply for permission to work and study in the UK')
    end
  end

  describe 'uk_residency_status_code' do
    it 'returns A if one of the candidate nationalities is GB' do
      application_form = build_stubbed(:application_form,
                                       :minimum_info,
                                       first_nationality: 'Irish',
                                       second_nationality: 'British')
      application_choice = build_stubbed(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.dig(:attributes, :candidate, :uk_residency_status_code)).to eq('A')
    end

    it 'returns B if one of the candidate nationalities is IE' do
      application_form = build_stubbed(:application_form,
                                       :minimum_info,
                                       first_nationality: 'Canadian',
                                       second_nationality: 'Irish')
      application_choice = build_stubbed(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.dig(:attributes, :candidate, :uk_residency_status_code)).to eq('B')
    end

    it 'returns C if the candidate does not have residency or right to work in UK' do
      application_form = build_stubbed(:application_form,
                                       :minimum_info,
                                       first_nationality: 'Canadian',
                                       right_to_work_or_study: 'no')
      application_choice = build_stubbed(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.dig(:attributes, :candidate, :uk_residency_status_code)).to eq('C')
    end

    it 'returns C if the candidate wishes to answer residency questions later' do
      application_form = build_stubbed(:application_form,
                                       :minimum_info,
                                       first_nationality: 'Canadian',
                                       right_to_work_or_study: 'decide_later')
      application_choice = build_stubbed(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.dig(:attributes, :candidate, :uk_residency_status_code)).to eq('C')
    end

    it 'returns D if the candidate has UK residency' do
      application_form = build_stubbed(:application_form,
                                       :minimum_info,
                                       first_nationality: 'Canadian',
                                       right_to_work_or_study: 'yes',
                                       right_to_work_or_study_details: 'I have Settled status')
      application_choice = build_stubbed(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.dig(:attributes, :candidate, :uk_residency_status_code)).to eq('D')
    end
  end

  describe 'attributes.candidate.fee_payer' do
    it 'returns 02 if the nationality is provisionally eligible for government funding' do
      application_form = create(:application_form, :minimum_info, first_nationality: 'British')
      application_choice = create(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.dig(:attributes, :candidate, :fee_payer)).to eq('02')
    end

    it 'returns 02 if the candidate is EU, EEA or Swiss national, has the right to work/study in the UK and their domicile is the UK' do
      application_form = create(:application_form, :minimum_info, first_nationality: 'Swiss', right_to_work_or_study: 'yes')
      application_choice = create(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.dig(:attributes, :candidate, :fee_payer)).to eq('02')
    end

    it 'returns 99 if the candidate is not British, Irish, EU, EEA or Swiss national' do
      application_form = create(:application_form, :minimum_info, first_nationality: 'Canadian')
      application_choice = create(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.dig(:attributes, :candidate, :fee_payer)).to eq('99')
    end

    it 'returns 99 if the candidate does not have the right to work/study in the UK' do
      application_form = create(:application_form, :minimum_info, first_nationality: 'Swiss', right_to_work_or_study: 'no')
      application_choice = create(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.dig(:attributes, :candidate, :fee_payer)).to eq('99')
    end

    it 'returns 99 if the candidate does not reside in the UK' do
      application_form = create(:application_form, :minimum_info, :international_address, first_nationality: 'Swiss', right_to_work_or_study: 'yes')
      application_choice = create(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.dig(:attributes, :candidate, :fee_payer)).to eq('99')
    end
  end

  describe 'attributes.candidate.english_language_qualifications' do
    it 'returns a description of the candidate\'s EFL qualification' do
      application_form = create(:completed_application_form, english_proficiency: create(:english_proficiency, :with_toefl_qualification))

      application_choice = create(:application_choice, :awaiting_provider_decision, application_form: application_form)

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.dig(:attributes, :candidate, :english_language_qualifications)).to eq('Name: TOEFL, Grade: 20, Awarded: 1999')
    end

    it 'prefers to return description of the candidate\'s EFL qualification over the deprecatd english_language_details' do
      application_form = create(
        :completed_application_form,
        english_language_details: 'I have taken some exams but I do not remember the names',
        english_proficiency: create(:english_proficiency, :with_toefl_qualification),
      )

      application_choice = create(:application_choice, :awaiting_provider_decision, application_form: application_form)

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.dig(:attributes, :candidate, :english_language_qualifications)).to eq('Name: TOEFL, Grade: 20, Awarded: 1999')
    end

    it 'returns english_language_details is a candidate has not provided an EFL qualification' do
      application_form = create(
        :completed_application_form,
        english_language_details: 'I have taken some exams but I do not remember the names',
      )

      application_choice = create(:application_choice, :awaiting_provider_decision, application_form: application_form)

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.dig(:attributes, :candidate, :english_language_qualifications)).to eq('I have taken some exams but I do not remember the names')
    end
  end

  describe 'attributes.contact_details' do
    it 'returns contact details in correct format for UK addresses' do
      application_form_attributes = {
        phone_number: '07700 900 982',
        address_line1: '42',
        address_line2: 'Much Wow Street',
        address_line3: 'London',
        address_line4: 'England',
        country: 'GB',
        postcode: 'SW1P 3BT',
      }
      application_form = create(
        :application_form,
        :minimum_info,
        application_form_attributes,
      )
      application_choice = create(
        :application_choice,
        status: 'awaiting_provider_decision',
        application_form: application_form,
      )

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expected_contact_details = application_form_attributes.merge(email: application_form.candidate.email_address)
      expect(response.to_json).to be_valid_against_openapi_schema('Application')
      expect(response.dig(:attributes, :contact_details)).to eq expected_contact_details
    end

    it 'returns contact details in correct format for international addresses' do
      application_form_attributes = {
        phone_number: '07700 900 982',
        address_type: 'international',
        address_line1: '456 Marine Drive',
        address_line2: 'Mumbai',
        address_line3: nil,
        address_line4: nil,
        international_address: '456 Marine Drive, Mumbai',
        country: 'IN',
      }
      application_form = create(
        :application_form,
        :minimum_info,
        application_form_attributes,
      )
      application_choice = create(
        :application_choice,
        status: 'awaiting_provider_decision',
        application_form: application_form,
      )

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.to_json).to be_valid_against_openapi_schema('Application')
      expect(response.dig(:attributes, :contact_details)).to eq({
        phone_number: '07700 900 982',
        address_line1: '456 Marine Drive',
        address_line2: 'Mumbai',
        address_line3: nil,
        address_line4: nil,
        country: 'IN',
        email: application_form.candidate.email_address,
      })
    end

    it 'presents the international_address field if no address lines are populated' do
      application_form_attributes = {
        phone_number: '07700 900 982',
        address_type: 'international',
        international_address: '456 Marine Drive, Mumbai',
        address_line1: nil,
        address_line2: nil,
        address_line3: nil,
        address_line4: nil,
        country: 'IN',
      }
      application_form = create(
        :application_form,
        :minimum_info,
        application_form_attributes,
      )
      application_choice = create(
        :application_choice,
        status: 'awaiting_provider_decision',
        application_form: application_form,
      )

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.to_json).to be_valid_against_openapi_schema('Application')
      expect(response.dig(:attributes, :contact_details)).to eq({
        phone_number: '07700 900 982',
        address_line1: '456 Marine Drive, Mumbai',
        address_line2: nil,
        address_line3: nil,
        address_line4: nil,
        country: 'IN',
        email: application_form.candidate.email_address,
      })
    end
  end

  describe 'attributes.safeguarding_issues_status' do
    it 'returns the safeguarding issues status' do
      application_form = create(:application_form, :minimum_info, :with_safeguarding_issues_disclosed)
      application_choice = create(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.dig(:attributes, :safeguarding_issues_status)).to eq('has_safeguarding_issues_to_declare')
    end
  end

  describe 'attributes.safeguarding_issues_details_url' do
    it 'returns the url if the status is has_safeguarding_issues_to_declare' do
      application_form = create(:application_form, :minimum_info, :with_safeguarding_issues_disclosed)
      application_choice = create(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.dig(:attributes, :safeguarding_issues_details_url)).to include("/provider/applications/#{application_choice.id}#criminal-convictions-and-professional-misconduct")
    end

    it 'returns nil if the status is no_safeguarding_issues_to_declare' do
      application_form = build(:application_form, :minimum_info)
      application_choice = create(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.dig(:attributes, :safeguarding_issues_details_url)).to eq(nil)
    end

    it 'returns nil if the status is never_asked' do
      application_form = create(:application_form, :minimum_info, :with_safeguarding_issues_never_asked)
      application_choice = create(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.dig(:attributes, :safeguarding_issues_details_url)).to eq(nil)
    end
  end

  describe 'attributes.references' do
    let(:application_choice) { create(:application_choice, :with_completed_application_form, :with_offer) }

    it 'returns only references with feedback which were selected by the candidate' do
      with_feedback_and_selected = create(
        :selected_reference,
        application_form: application_choice.application_form,
      )

      with_feedback_but_not_selected = create(
        :reference,
        :feedback_provided,
        application_form: application_choice.application_form,
      )

      refused = create(
        :reference,
        :feedback_refused,
        application_form: application_choice.application_form,
      )

      presenter = VendorAPI::SingleApplicationPresenter.new(application_choice)
      expect(presenter.as_json[:attributes][:references].map { |r| r[:id] }).to include(with_feedback_and_selected.id)
      expect(presenter.as_json[:attributes][:references].map { |r| r[:id] }).not_to include(with_feedback_but_not_selected.id)
      expect(presenter.as_json[:attributes][:references].map { |r| r[:id] }).not_to include(refused.id)
    end

    it 'returns application references with their respective ids' do
      reference = create(
        :selected_reference,
        application_form: application_choice.application_form,
      )
      presenter = VendorAPI::SingleApplicationPresenter.new(application_choice)
      expect(presenter.as_json[:attributes][:references].first[:id]).to eq(reference.id)
    end

    it 'includes safeguarding concerns' do
      create(
        :selected_reference,
        safeguarding_concerns_status: 'has_safeguarding_concerns_to_declare',
        application_form: application_choice.application_form,
      )

      create(
        :selected_reference,
        safeguarding_concerns_status: 'no_safeguarding_concerns_to_declare',
        application_form: application_choice.application_form,
      )

      presenter = VendorAPI::SingleApplicationPresenter.new(application_choice)
      expect(presenter.as_json[:attributes][:references].map { |r| r[:safeguarding_concerns] })
        .to match_array [true, false]
    end
  end

  describe 'attributes.qualifications' do
    let(:application_choice) { create(:application_choice, :with_completed_application_form, :with_offer) }
    let(:presenter) { VendorAPI::SingleApplicationPresenter.new(application_choice) }

    it 'uses the public_id of a qualification as the id' do
      qualification = create(
        :other_qualification,
        application_form: application_choice.application_form,
      )

      qualification_hash = presenter.as_json.dig(
        :attributes,
        :qualifications,
        :other_qualifications,
      ).first

      expect(qualification_hash[:id]).to eq qualification.public_id
    end

    it 'contains HESA qualification fields' do
      create(
        :other_qualification,
        :non_uk,
        application_form: application_choice.application_form,
      )

      qualification_hash = presenter.as_json.dig(
        :attributes,
        :qualifications,
        :other_qualifications,
      ).first

      expect(qualification_hash).to have_key(:hesa_degstdt)
    end

    it 'contains equivalency_details' do
      qualification = create(
        :other_qualification,
        :non_uk,
        application_form: application_choice.application_form,
      )

      equivalency_details = presenter.as_json.dig(
        :attributes,
        :qualifications,
        :other_qualifications,
      ).first[:equivalency_details]

      expect(equivalency_details).to eq(qualification.equivalency_details)
    end

    it 'adds ENIC information, if present, to equivalency_details' do
      qualification = create(
        :gcse_qualification,
        :non_uk,
        application_form: application_choice.application_form,
      )

      equivalency_details = presenter.as_json.dig(
        :attributes,
        :qualifications,
        :gcses,
      ).first[:equivalency_details]

      composite_equivalency_details = [
        "Enic: #{qualification.enic_reference}",
        qualification.comparable_uk_qualification,
        qualification.equivalency_details,
      ].join(' - ')

      expect(equivalency_details).to eq(composite_equivalency_details)
    end

    it 'includes a non_uk_qualification_type for non-UK qualifications' do
      create(
        :gcse_qualification,
        :non_uk,
        non_uk_qualification_type: 'High School Diploma',
        application_form: application_choice.application_form,
      )

      qualification = presenter.as_json.dig(
        :attributes,
        :qualifications,
        :gcses,
      ).find { |q| q[:non_uk_qualification_type] == 'High School Diploma' }

      expect(qualification[:non_uk_qualification_type]).to eq 'High School Diploma'
    end

    it 'renders missing grades as "Not Entered"' do
      create(
        :gcse_qualification,
        grade: nil,
        application_form: application_choice.application_form,
      )

      qualification = presenter.as_json.dig(
        :attributes,
        :qualifications,
        :gcses,
      ).first

      expect(qualification[:grade]).to eq 'Not entered'
    end

    describe 'subject_code' do
      it 'maps gcse level science qualifications correctly' do
        science_triple_awards = {
          biology: { grade: 'A' },
          chemistry: { grade: 'B' },
          physics: { grade: 'C' },
        }

        create(
          :gcse_qualification,
          grade: nil,
          subject: 'science triple award',
          constituent_grades: science_triple_awards,
          application_form: application_choice.application_form,
        )

        qualification = presenter.as_json.dig(
          :attributes,
          :qualifications,
          :gcses,
        ).find { |q| q[:subject] == 'science triple award' }

        expect(qualification[:subject_code]).to eq '100390'
      end

      it 'maps gcse level english qualifications correctly' do
        create(
          :gcse_qualification,
          grade: nil,
          subject: 'english',
          constituent_grades: {
            english_language: { grade: 'E', public_id: 1 },
            english_literature: { grade: 'E', public_id: 2 },
          },
          application_form: application_choice.application_form,
        )

        language_qualification = presenter.as_json.dig(
          :attributes,
          :qualifications,
          :gcses,
        ).find { |q| q[:subject] == 'English language' }

        expect(language_qualification[:subject_code]).to eq '100318'

        language_qualification = presenter.as_json.dig(
          :attributes,
          :qualifications,
          :gcses,
        ).find { |q| q[:subject] == 'English literature' }

        expect(language_qualification[:subject_code]).to eq '100319'
      end

      it 'maps gcse level maths qualifications correctly' do
        create(
          :gcse_qualification,
          grade: 'A',
          subject: 'maths',
          application_form: application_choice.application_form,
        )

        qualification = presenter.as_json.dig(
          :attributes,
          :qualifications,
          :gcses,
        ).find { |q| q[:subject] == 'maths' }

        expect(qualification[:subject_code]).to eq '100403'
      end

      it 'maps other GCSE qualifications correctly from the autocomplete list' do
        gcse_subject = GCSE_SUBJECTS.sample
        create(
          :other_qualification,
          grade: 'B',
          subject: gcse_subject,
          qualification_type: 'GCSE',
          application_form: application_choice.application_form,
        )

        qualification = presenter.as_json.dig(
          :attributes,
          :qualifications,
          :other_qualifications,
        ).find { |q| q[:subject] == gcse_subject }

        expect(qualification[:subject_code]).to eq(GCSE_SUBJECTS_TO_CODES[gcse_subject])
      end

      it 'maps other A level qualifications correctly from the autocomplete list' do
        a_level_subject = A_AND_AS_LEVEL_SUBJECTS.sample
        create(
          :other_qualification,
          grade: 'C',
          subject: a_level_subject,
          qualification_type: 'A level',
          application_form: application_choice.application_form,
        )

        qualification = presenter.as_json.dig(
          :attributes,
          :qualifications,
          :other_qualifications,
        ).find { |q| q[:subject] == a_level_subject }

        expect(qualification[:subject_code]).to eq(A_AND_AS_LEVEL_SUBJECTS_TO_CODES[a_level_subject])
      end

      it 'leaves the subject code blank when the subject is not recognised' do
        create(
          :other_qualification,
          grade: 'C',
          subject: 'Harry potter books and films',
          qualification_type: 'A level',
          application_form: application_choice.application_form,
        )

        qualification = presenter.as_json.dig(
          :attributes,
          :qualifications,
          :other_qualifications,
        ).find { |q| q[:subject] == 'Harry potter books and films' }

        expect(qualification[:subject_code]).to be_nil
      end
    end

    it 'adds GCSE science triple award information' do
      science_triple_awards = {
        biology: { grade: 'A' },
        chemistry: { grade: 'B' },
        physics: { grade: 'C' },
      }

      create(
        :gcse_qualification,
        public_id: 4,
        grade: nil,
        subject: 'science triple award',
        constituent_grades: science_triple_awards,
        application_form: application_choice.application_form,
      )

      qualification = presenter.as_json.dig(
        :attributes,
        :qualifications,
        :gcses,
      ).find { |q| q[:subject] == 'science triple award' }

      expect(qualification[:id]).to eq 4
      expect(qualification[:grade]).to eq 'ABC'
    end

    it 'parses English GCSE structured grades' do
      create(
        :gcse_qualification,
        subject: 'english',
        grade: nil,
        constituent_grades: {
          english_language: { grade: 'E', public_id: 1 },
          english_literature: { grade: 'E', public_id: 2 },
          'Cockney Rhyming Slang': { grade: 'A*', public_id: 3 },
        },
        award_year: 2006,
        predicted_grade: false,
        application_form: application_choice.application_form,
      )

      english_language = presenter.as_json.dig(
        :attributes,
        :qualifications,
        :gcses,
      ).find { |q| q[:subject] == 'English language' }

      expect(english_language[:id]).to eq 1
      expect(english_language[:grade]).to eq 'E'

      english_literature = presenter.as_json.dig(
        :attributes,
        :qualifications,
        :gcses,
      ).find { |q| q[:subject] == 'English literature' }

      expect(english_literature[:id]).to eq 2
      expect(english_literature[:grade]).to eq 'E'

      rhyming_slang = presenter.as_json.dig(
        :attributes,
        :qualifications,
        :gcses,
      ).find { |q| q[:subject] == 'Cockney rhyming slang' }

      expect(rhyming_slang[:id]).to eq 3
      expect(rhyming_slang[:grade]).to eq 'A*'
    end
  end

  describe 'attributes.offer' do
    it 'includes an offer_made_at date for offers' do
      choice = create(:application_choice, :with_completed_application_form, :with_offer)

      presenter = VendorAPI::SingleApplicationPresenter.new(choice)
      expect(presenter.as_json[:attributes][:offer][:offer_made_at]).to be_present
    end

    it 'includes an accepted_at date for accepted offers' do
      choice = create(:application_choice, :with_completed_application_form, :with_accepted_offer)

      presenter = VendorAPI::SingleApplicationPresenter.new(choice)
      expect(presenter.as_json[:attributes][:offer][:offer_accepted_at]).to be_present
    end

    it 'includes a declined_at date for declined offers' do
      choice = create(:application_choice, :with_completed_application_form, :with_declined_offer)

      presenter = VendorAPI::SingleApplicationPresenter.new(choice)
      expect(presenter.as_json[:attributes][:offer][:offer_declined_at]).to be_present
    end
  end

  describe 'attributes.recruited_at' do
    it 'includes the date the candidate was recruited' do
      choice = create(:application_choice, :with_completed_application_form, :with_recruited)

      presenter = VendorAPI::SingleApplicationPresenter.new(choice)
      expect(presenter.as_json[:attributes][:recruited_at]).to be_present
    end
  end

  describe 'attributes.status' do
    it 'returns awaiting_provider_decision when status is interviewing' do
      application_choice = build_stubbed(:application_choice, :with_completed_application_form, status: :interviewing)
      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json
      expect(response.dig(:attributes)[:status]).to eq('awaiting_provider_decision')
    end
  end

  describe 'compliance with models that change updated_at' do
    let(:non_uk_application_form) do
      create(
        :application_form,
        :minimum_info,
        first_nationality: 'Spanish',
        right_to_work_or_study: :yes,
        address_type: :international,
        address_line1: nil,
      )
    end
    let(:non_uk_application_choice) { create(:submitted_application_choice, application_form: non_uk_application_form) }
    let(:application_choice) { create(:submitted_application_choice, :with_completed_application_form) }

    it 'looks at all fields which cause a touch' do
      # if there is a field on the form that causes a touch but isn't
      # queried via the presenter on the API, fail this test
      ApplicationForm::PUBLISHED_FIELDS.each do |field|
        allow(non_uk_application_form).to receive(field).and_call_original
        allow(application_choice.application_form).to receive(field).and_call_original
      end

      VendorAPI::SingleApplicationPresenter.new(application_choice).as_json
      VendorAPI::SingleApplicationPresenter.new(non_uk_application_choice).as_json

      (ApplicationForm::PUBLISHED_FIELDS - %w[postcode equality_and_diversity]).each do |field|
        expect(non_uk_application_form).to have_received(field).at_least(:once)
      end

      (ApplicationForm::PUBLISHED_FIELDS - %w[international_address right_to_work_or_study_details equality_and_diversity]).each do |field|
        expect(application_choice.application_form).to have_received(field).at_least(:once)
      end
    end

    it 'doesn’t depend on any fields that don’t cause a touch' do
      (ApplicationForm.attribute_names - %w[id] - ApplicationForm::PUBLISHED_FIELDS).each do |field|
        allow(non_uk_application_form).to receive(field).and_call_original
        allow(application_choice.application_form).to receive(field).and_call_original
      end

      VendorAPI::SingleApplicationPresenter.new(application_choice).as_json
      VendorAPI::SingleApplicationPresenter.new(non_uk_application_choice).as_json

      (ApplicationForm.attribute_names - %w[id] - ApplicationForm::PUBLISHED_FIELDS).each do |field|
        expect(non_uk_application_form).not_to have_received(field)
        expect(application_choice.application_form).not_to have_received(field)
      end
    end
  end
end
