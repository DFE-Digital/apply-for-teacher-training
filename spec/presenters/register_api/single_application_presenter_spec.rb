require 'rails_helper'

# To avoid this test becoming too large, only use this spec to test complex
# logic in the presenter. For anything that is passed straight from the database
# to the API, make sure that spec/system/register_api/register_receives_application_spec.rb is updated.
RSpec.describe RegisterAPI::SingleApplicationPresenter do
  describe 'attributes.hesa_itt_data' do
    context "when an application choice has status 'recruited'" do
      let(:application_choice) do
        application_form = create(:application_form,
                                  :minimum_info,
                                  :with_equality_and_diversity_data)
        create(:application_choice, :with_recruited, application_form: application_form)
      end

      it 'returns the hesa_itt_data attribute of an application' do
        equality_and_diversity_data = application_choice.application_form.equality_and_diversity

        response = described_class.new(application_choice).as_json

        expect(response.dig(:attributes, :hesa_itt_data)).to eq(
          disability: equality_and_diversity_data['hesa_disabilities'],
          ethnicity: equality_and_diversity_data['hesa_ethnicity'],
          sex: equality_and_diversity_data['hesa_sex'],
        )
      end
    end
  end

  describe 'attributes.candidate.nationality' do
    it 'compacts two nationalities with the same ISO value' do
      application_form = create(:application_form,
                                :minimum_info,
                                first_nationality: 'Welsh',
                                second_nationality: 'Scottish')
      application_choice = create(:application_choice, :with_recruited, application_form: application_form)

      response = described_class.new(application_choice).as_json

      expect(response.dig(:attributes, :candidate, :nationality)).to eq %w[GB]
    end

    it 'returns nationality in the correct format' do
      application_form = create(:application_form,
                                :minimum_info,
                                first_nationality: 'British',
                                second_nationality: 'American')
      application_choice = create(:application_choice, :with_recruited, application_form: application_form)

      response = described_class.new(application_choice).as_json

      expect(response[:attributes][:candidate][:nationality]).to eq(%w[GB US])
    end

    it 'returns sorted array of nationalties so British or Irish are first' do
      application_form = create(:application_form,
                                :minimum_info,
                                first_nationality: 'Canadian',
                                second_nationality: 'Spanish',
                                third_nationality: 'Irish',
                                fourth_nationality: 'Welsh')
      application_choice = create(:application_choice, :with_recruited, application_form: application_form)

      response = described_class.new(application_choice).as_json

      expect(response.dig(:attributes, :candidate, :nationality)).to eq(%w[GB IE CA ES])
    end
  end

  describe 'attributes.candidate.domicile' do
    it 'uses DomicileResolver to return a HESA code' do
      application_form = create(:application_form, :minimum_info)
      application_choice = create(:application_choice, :with_recruited, application_form: application_form)

      response = described_class.new(application_choice).as_json

      expect(response.dig(:attributes, :candidate, :domicile)).to eq(application_form.domicile)
    end
  end

  describe 'attributes.candidate.uk_residency_status' do
    it 'returns UK Citizen if the candidates nationalties include UK' do
      application_form = create(:application_form,
                                :minimum_info,
                                first_nationality: 'Irish',
                                second_nationality: 'British')
      application_choice = create(:application_choice, :with_recruited, application_form: application_form)

      response = described_class.new(application_choice).as_json

      expect(response.dig(:attributes, :candidate, :uk_residency_status)).to eq('UK Citizen')
    end

    it 'returns Irish Citizen if the candidates nationalties is Irish' do
      application_form = create(:application_form,
                                :minimum_info,
                                first_nationality: 'Canadian',
                                second_nationality: 'Irish')
      application_choice = create(:application_choice, :with_recruited, application_form: application_form)

      response = described_class.new(application_choice).as_json

      expect(response.dig(:attributes, :candidate, :uk_residency_status)).to eq('Irish Citizen')
    end

    it 'returns details of the immigration status if the candidates answered the have the right to work/study in the UK' do
      application_form = create(:application_form,
                                :minimum_info,
                                first_nationality: 'Canadian',
                                right_to_work_or_study: 'yes',
                                right_to_work_or_study_details: 'I have Settled status')
      application_choice = create(:application_choice, :with_recruited, application_form: application_form)

      response = described_class.new(application_choice).as_json

      expect(response.dig(:attributes, :candidate, :uk_residency_status)).to eq('I have Settled status')
    end

    it 'returns correct message if the candidates answered they do not yet have the right to work/study in the UK' do
      application_form = create(:application_form,
                                :minimum_info,
                                first_nationality: 'Canadian',
                                right_to_work_or_study: 'no')
      application_choice = create(:application_choice, :with_recruited, application_form: application_form)

      response = described_class.new(application_choice).as_json

      expect(response.dig(:attributes, :candidate, :uk_residency_status)).to eq('Candidate needs to apply for permission to work and study in the UK')
    end

    it 'returns correct message if the candidate has answered they do not know if they have the right to work/study in the UK' do
      application_form = create(:application_form,
                                :minimum_info,
                                first_nationality: 'Canadian',
                                right_to_work_or_study: 'decide_later')
      application_choice = create(:application_choice, :with_recruited, application_form: application_form)

      response = described_class.new(application_choice).as_json

      expect(response.dig(:attributes, :candidate, :uk_residency_status)).to eq('Candidate needs to apply for permission to work and study in the UK')
    end
  end

  describe 'uk_residency_status_code' do
    it 'returns A if one of the candidate nationalities is GB' do
      application_form = build_stubbed(:application_form,
                                       :minimum_info,
                                       first_nationality: 'Irish',
                                       second_nationality: 'British')
      application_choice = build_stubbed(:application_choice, :with_recruited, application_form: application_form)

      response = described_class.new(application_choice).as_json

      expect(response.dig(:attributes, :candidate, :uk_residency_status_code)).to eq('A')
    end

    it 'returns B if one of the candidate nationalities is IE' do
      application_form = build_stubbed(:application_form,
                                       :minimum_info,
                                       first_nationality: 'Canadian',
                                       second_nationality: 'Irish')
      application_choice = build_stubbed(:application_choice, :with_recruited, application_form: application_form)

      response = described_class.new(application_choice).as_json

      expect(response.dig(:attributes, :candidate, :uk_residency_status_code)).to eq('B')
    end

    it 'returns C if the candidate does not have residency or right to work in UK' do
      application_form = build_stubbed(:application_form,
                                       :minimum_info,
                                       first_nationality: 'Canadian',
                                       right_to_work_or_study: 'no')
      application_choice = build_stubbed(:application_choice, :with_recruited, application_form: application_form)

      response = described_class.new(application_choice).as_json

      expect(response.dig(:attributes, :candidate, :uk_residency_status_code)).to eq('C')
    end

    it 'returns C if the candidate wishes to answer residency questions later' do
      application_form = build_stubbed(:application_form,
                                       :minimum_info,
                                       first_nationality: 'Canadian',
                                       right_to_work_or_study: 'decide_later')
      application_choice = build_stubbed(:application_choice, :with_recruited, application_form: application_form)

      response = described_class.new(application_choice).as_json

      expect(response.dig(:attributes, :candidate, :uk_residency_status_code)).to eq('C')
    end

    it 'returns D if the candidate has UK residency' do
      application_form = build_stubbed(:application_form,
                                       :minimum_info,
                                       first_nationality: 'Canadian',
                                       right_to_work_or_study: 'yes',
                                       right_to_work_or_study_details: 'I have Settled status')
      application_choice = build_stubbed(:application_choice, :with_recruited, application_form: application_form)

      response = described_class.new(application_choice).as_json

      expect(response.dig(:attributes, :candidate, :uk_residency_status_code)).to eq('D')
    end
  end

  describe 'attributes.candidate.fee_payer' do
    it 'returns 02 if the nationality is provisionally eligible for government funding' do
      application_form = create(:application_form, :minimum_info, first_nationality: 'British')
      application_choice = create(:application_choice, :with_recruited, application_form: application_form)

      response = described_class.new(application_choice).as_json

      expect(response.dig(:attributes, :candidate, :fee_payer)).to eq('02')
    end

    it 'returns 02 if the candidate is EU, EEA or Swiss national, has the right to work/study in the UK and their domicile is the UK' do
      application_form = create(:application_form, :minimum_info, first_nationality: 'Swiss', right_to_work_or_study: 'yes')
      application_choice = create(:application_choice, :with_recruited, application_form: application_form)

      response = described_class.new(application_choice).as_json

      expect(response.dig(:attributes, :candidate, :fee_payer)).to eq('02')
    end

    it 'returns 99 if the candidate is not British, Irish, EU, EEA or Swiss national' do
      application_form = create(:application_form, :minimum_info, first_nationality: 'Canadian')
      application_choice = create(:application_choice, :with_recruited, application_form: application_form)

      response = described_class.new(application_choice).as_json

      expect(response.dig(:attributes, :candidate, :fee_payer)).to eq('99')
    end

    it 'returns 99 if the candidate does not have the right to work/study in the UK' do
      application_form = create(:application_form, :minimum_info, first_nationality: 'Swiss', right_to_work_or_study: 'no')
      application_choice = create(:application_choice, :with_recruited, application_form: application_form)

      response = described_class.new(application_choice).as_json

      expect(response.dig(:attributes, :candidate, :fee_payer)).to eq('99')
    end

    it 'returns 99 if the candidate does not reside in the UK' do
      application_form = create(:application_form, :minimum_info, :international_address, first_nationality: 'Swiss', right_to_work_or_study: 'yes')
      application_choice = create(:application_choice, :with_recruited, application_form: application_form)

      response = described_class.new(application_choice).as_json

      expect(response.dig(:attributes, :candidate, :fee_payer)).to eq('99')
    end
  end

  describe 'attributes.candidate.english_language_qualifications' do
    it 'returns a description of the candidate\'s EFL qualification' do
      application_form = create(:completed_application_form, english_proficiency: create(:english_proficiency, :with_toefl_qualification))

      application_choice = create(:application_choice, :with_recruited, application_form: application_form)

      response = described_class.new(application_choice).as_json

      expect(response.dig(:attributes, :candidate, :english_language_qualifications)).to eq('Name: TOEFL, Grade: 20, Awarded: 1999')
    end

    it 'prefers to return description of the candidate\'s EFL qualification over the deprecatd english_language_details' do
      application_form = create(
        :completed_application_form,
        english_language_details: 'I have taken some exams but I do not remember the names',
        english_proficiency: create(:english_proficiency, :with_toefl_qualification),
      )

      application_choice = create(:application_choice, :with_recruited, application_form: application_form)

      response = described_class.new(application_choice).as_json

      expect(response.dig(:attributes, :candidate, :english_language_qualifications)).to eq('Name: TOEFL, Grade: 20, Awarded: 1999')
    end

    it 'returns english_language_details is a candidate has not provided an EFL qualification' do
      application_form = create(
        :completed_application_form,
        english_language_details: 'I have taken some exams but I do not remember the names',
      )

      application_choice = create(:application_choice, :with_recruited, application_form: application_form)

      response = described_class.new(application_choice).as_json

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
        :with_recruited,
        application_form: application_form,
      )

      response = described_class.new(application_choice).as_json

      expected_contact_details = application_form_attributes.merge(email: application_form.candidate.email_address)
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
        :with_recruited,
        application_form: application_form,
      )

      response = described_class.new(application_choice).as_json

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
        :with_recruited,
        application_form: application_form,
      )

      response = described_class.new(application_choice).as_json

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

  describe 'attributes.course' do
    let(:application_choice) { create(:application_choice, :with_completed_application_form, :with_offer, :with_recruited, course: course) }
    let(:training_provider) { create(:provider, provider_type: 'scitt') }
    let(:accredited_provider) { create(:provider, provider_type: 'university') }
    let(:course) { create(:course, provider: training_provider, accredited_provider: accredited_provider) }
    let(:presenter) { described_class.new(application_choice).as_json }

    it 'returns the course training provider type' do
      expect(presenter.dig(:attributes, :course, :training_provider_type)).to eq('scitt')
    end

    it 'returns the course accredited provider type' do
      expect(presenter.dig(:attributes, :course, :accredited_provider_type)).to eq('university')
    end

    context 'with a self ratified course' do
      let(:accredited_provider) { nil }

      it 'returns no accredited provider type' do
        expect(presenter.dig(:attributes, :course, :accredited_provider_type)).to be_nil
      end
    end
  end

  describe 'attributes.qualifications' do
    let(:application_choice) { create(:application_choice, :with_completed_application_form, :with_offer, :with_recruited) }
    let(:presenter) { described_class.new(application_choice) }

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

  describe 'attributes.recruited_at' do
    it 'includes the date the candidate was recruited' do
      choice = create(:application_choice, :with_completed_application_form, :with_recruited)

      presenter = described_class.new(choice)
      expect(presenter.as_json[:attributes][:recruited_at]).to be_present
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
    let(:non_uk_application_choice) { create(:submitted_application_choice, :with_recruited, application_form: non_uk_application_form) }
    let(:application_choice) { create(:submitted_application_choice, :with_completed_application_form, :with_recruited) }

    it 'looks at all fields which cause a touch' do
      # if there is a field on the form that causes a touch but isn't
      # queried via the presenter on the API, fail this test
      ApplicationForm::PUBLISHED_FIELDS.each do |field|
        allow(non_uk_application_form).to receive(field).and_call_original
        allow(application_choice.application_form).to receive(field).and_call_original
      end

      described_class.new(application_choice).as_json
      described_class.new(non_uk_application_choice).as_json

      not_included_in_register_api = %w[phase becoming_a_teacher subject_knowledge interview_preferences further_information safeguarding_issues_status work_history_breaks phone_number]

      (ApplicationForm::PUBLISHED_FIELDS - %w[postcode equality_and_diversity] - not_included_in_register_api).each do |field|
        expect(non_uk_application_form).to have_received(field).at_least(:once)
      end

      (ApplicationForm::PUBLISHED_FIELDS - %w[international_address right_to_work_or_study_details equality_and_diversity] - not_included_in_register_api).each do |field|
        expect(application_choice.application_form).to have_received(field).at_least(:once)
      end
    end

    it 'doesn’t depend on any fields that don’t cause a touch' do
      (ApplicationForm.attribute_names - %w[id] - ApplicationForm::PUBLISHED_FIELDS).each do |field|
        allow(non_uk_application_form).to receive(field).and_call_original
        allow(application_choice.application_form).to receive(field).and_call_original
      end

      described_class.new(application_choice).as_json
      described_class.new(non_uk_application_choice).as_json

      (ApplicationForm.attribute_names - %w[id] - ApplicationForm::PUBLISHED_FIELDS).each do |field|
        expect(non_uk_application_form).not_to have_received(field)
        expect(application_choice.application_form).not_to have_received(field)
      end
    end
  end
end
