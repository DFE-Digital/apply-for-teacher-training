require 'rails_helper'

RSpec.describe ApplicationForm do
  it { is_expected.to belong_to(:candidate).touch(true) }
  it { is_expected.to belong_to(:previous_application_form).class_name('ApplicationForm').optional.inverse_of('subsequent_application_form') }

  it { is_expected.to have_one(:subsequent_application_form).class_name('ApplicationForm').with_foreign_key('previous_application_form_id').inverse_of('previous_application_form') }
  it { is_expected.to have_one(:english_proficiency) }
  it { is_expected.to have_one :recruitment_cycle_timetable }

  it { is_expected.to have_many(:application_choices) }
  it { is_expected.to have_many(:course_options).through(:application_choices) }
  it { is_expected.to have_many(:courses).through(:application_choices) }
  it { is_expected.to have_many(:providers).through(:application_choices) }
  it { is_expected.to have_many(:application_work_experiences) }
  it { is_expected.to have_many(:application_volunteering_experiences) }
  it { is_expected.to have_many(:application_qualifications) }
  it { is_expected.to have_many(:degree_qualifications).class_name('ApplicationQualification').conditions(level: 'degree') }
  it { is_expected.to have_many(:application_references) }
  it { is_expected.to have_many(:application_work_history_breaks) }
  it { is_expected.to have_many(:emails) }
  it { is_expected.to have_many(:application_feedback) }

  describe '#cannot_add_more_choices?' do
    let(:application_form) { create(:application_form) }

    context 'when max number of choices' do
      before do
        create(:application_choice, :awaiting_provider_decision, application_form:)
        create(:application_choice, :rejected, application_form:)
        create(:application_choice, :inactive, application_form:)
        create(:application_choice, :awaiting_provider_decision, application_form:)
        create(:application_choice, :offered, application_form:)
        create(:application_choice, :offered, application_form:)
      end

      it 'returns true' do
        expect(application_form.cannot_add_more_choices?).to be(true)
      end
    end

    context 'when not max number of choices' do
      before do
        create(:application_choice, :awaiting_provider_decision, application_form:)
        create(:application_choice, :rejected, application_form:)
        create(:application_choice, :offered, application_form:)
      end

      it 'returns false' do
        expect(application_form.cannot_add_more_choices?).to be(false)
      end
    end
  end

  describe '#v23?' do
    subject(:application_form) do
      create(:application_form, recruitment_cycle_year:)
    end

    context 'when recruitment cycle is after continuous applications delivery', :continuous_applications do
      let(:recruitment_cycle_year) { 2024 }

      it 'returns true' do
        expect(application_form).not_to be_v23
      end
    end

    context 'when recruitment cycle is before continuous applications delivery' do
      let(:recruitment_cycle_year) { 2023 }

      it 'returns false' do
        expect(application_form).to be_v23
      end
    end
  end

  it 'sets a unique support reference upon creation' do
    create(:application_form, support_reference: 'AB1234')
    allow(GenerateSupportReference).to receive(:call).and_return('AB1234', 'OK1234')

    application_form = create(:application_form)

    expect(application_form.support_reference).to eql('OK1234')
  end

  describe 'before_save' do
    before do
      TestSuiteTimeMachine.unfreeze!
    end

    it 'updates the candidates `candidate_api_updated_at` when phase is updated' do
      application_form = create(:completed_application_form)

      expect { application_form.update(phase: 'apply_2') }
        .to(change { application_form.candidate.candidate_api_updated_at })
    end

    it 'updates the candidates `candidate_api_updated_at` on the first update' do
      application_form = create(:application_form, first_name: 'Bob')

      expect { application_form.update(first_name: 'David') }
        .to(change { application_form.candidate.candidate_api_updated_at })
    end

    it 'does not update the candidates `candidate_api_updated_at` on subsequent updates' do
      application_form = create(:application_form, first_name: 'Bob')

      application_form.update(first_name: 'Divad')

      expect { application_form.update(first_name: 'David') }
        .not_to(change { application_form.candidate.candidate_api_updated_at })
    end
  end

  describe 'after_save' do
    before do
      TestSuiteTimeMachine.unfreeze!
    end

    it 'touches the application choice when a field affecting the application choice is changed' do
      application_form = create(:completed_application_form, application_choices_count: 1)

      expect { application_form.update(first_name: 'a new name') }
        .to(change { application_form.application_choices.first.updated_at })
    end

    it 'does not touch the application choice when a field not affecting the application choice is changed' do
      application_form = create(:completed_application_form, application_choices_count: 1)

      expect { application_form.update(latitude: '0.12343') }
        .not_to(change { application_form.application_choices.first.updated_at })
    end

    context 'when the form belongs to a previous recruitment cycle' do
      before { RequestStore.store[:allow_unsafe_application_choice_touches] = false }

      it 'throws an exception rather than touch an application choice' do
        application_form = create(
          :completed_application_form,
          recruitment_cycle_year: previous_year,
          application_choices_count: 1,
          first_name: 'Mary',
        )

        expect { application_form.update(first_name: 'Maria') }
          .to raise_error('Tried to mark an application choice from a previous cycle as changed')
      end

      it 'does not throw an exception and touches an application choice when offer is deferred from last cycle' do
        application_form = create(
          :completed_application_form,
          recruitment_cycle_year: previous_year,
          application_choices_count: 1,
        )

        application_form.application_choices.update(status: 'offer_deferred')

        expect { application_form.update(address_line1: '123 Fake Street') }
          .not_to raise_error
      end

      it 'does not throw an exception when offer deferred from an even earlier cycle' do
        application_form = create(
          :completed_application_form,
          application_choices_count: 1,
        )

        application_form.application_choices.update(status: 'offer_deferred')
        application_form.update(recruitment_cycle_year: previous_year - 1)

        expect { application_form.update(address_line1: '123 Fake Street') }
          .not_to raise_error
      end

      it 'does nothing when there are no application choices' do
        application_form = create(
          :completed_application_form,
          recruitment_cycle_year: previous_year,
          application_choices_count: 0,
          first_name: 'Mary',
        )

        expect { application_form.update(first_name: 'Maria') }
          .not_to raise_error
      end

      context 'when we allow unsafe touches' do
        it 'does not throw an exception' do
          application_form = create(
            :completed_application_form,
            recruitment_cycle_year: previous_year,
            application_choices_count: 1,
            references_count: 0,
          )

          described_class.with_unsafe_application_choice_touches do
            expect { application_form.update(first_name: 'Maria') }
              .not_to raise_error
          end
        end
      end
    end
  end

  describe 'after_touch' do
    before do
      TestSuiteTimeMachine.unfreeze!
    end

    it 'touches the application choice when touched by a related model' do
      application_form = create(:completed_application_form, :with_gcses, application_choices_count: 1)

      expect { application_form.maths_gcse.update!(grade: 'D') }
        .to(change { application_form.application_choices.first.updated_at })
    end
  end

  describe 'after_update' do
    before do
      TestSuiteTimeMachine.unfreeze!
    end

    describe 'updating region code' do
      before do
        allow(LookupAreaByPostcodeWorker).to receive(:perform_in).and_return(nil)
      end

      it 'sets value to `rest_of_the_world` for international addresses outside EEA' do
        application_form = create(:application_form, region_code: :london)

        application_form.update!(
          country: 'IN',
          address_type: :international,
          international_address: '123 MG Road, Mumbai',
        )

        expect(LookupAreaByPostcodeWorker).not_to have_received(:perform_in)
        expect(application_form.reload.rest_of_the_world?).to be(true)
      end

      it 'sets value to `european_economic_area` for international addresses inside EEA' do
        application_form = create(:application_form, region_code: :london)

        application_form.update!(
          country: 'FR',
          address_type: :international,
          international_address: '123 Rue de Rivoli, Paris',
        )

        expect(LookupAreaByPostcodeWorker).not_to have_received(:perform_in)
        expect(application_form.reload.european_economic_area?).to be(true)
      end

      describe 'region from postcode' do
        it 'queues an LookupAreaByPostcodeWorker job for Westminster postcode' do
          application_form = create(:application_form)

          application_form.update!(
            address_type: :uk,
            postcode: 'SW1P 3BT',
          )

          expect(LookupAreaByPostcodeWorker).to have_received(:perform_in).with(anything, application_form.id)
        end

        it 'queues an LookupAreaByPostcodeWorker job for Cardiff postcode' do
          application_form = create(:application_form)

          application_form.update!(
            address_type: :uk,
            postcode: 'CF40 2QD',
          )

          expect(LookupAreaByPostcodeWorker).to have_received(:perform_in).with(anything, application_form.id)
        end
      end
    end

    describe 'geocoding address' do
      it 'invokes geocoding of UK addresses on create' do
        allow(GeocodeApplicationAddressWorker).to receive(:perform_in)
        application_form = create(:application_form, :minimum_info)

        application_form.update!(postcode: 'SE10NE')

        expect(GeocodeApplicationAddressWorker).to have_received(:perform_in).with(anything, application_form.id)
      end

      it 'invokes geocoding of UK addresses on update' do
        allow(GeocodeApplicationAddressWorker).to receive(:perform_in)
        application_form = create(:application_form, :minimum_info)

        address_attributes = %i[address_line1 address_line2 address_line3 address_line4 postcode country]
        address_attributes.each do |address_attr|
          application_form.update!(address_attr => 'foo')
        end

        expected_calls_to_worker = address_attributes.size # Each update excluding the initial create
        expect(GeocodeApplicationAddressWorker)
          .to have_received(:perform_in)
          .with(anything, application_form.id)
          .exactly(expected_calls_to_worker).times
      end

      it 'does not invoke geocoding for international addresses' do
        allow(GeocodeApplicationAddressWorker).to receive(:perform_in)

        application_form = create(:application_form, :minimum_info)

        application_form.update!(address_type: :international)

        expect(GeocodeApplicationAddressWorker).not_to have_received(:perform_in).with(application_form.id)
      end

      it 'does not invoke geocoding if address fields have not been changed' do
        allow(GeocodeApplicationAddressWorker).to receive(:perform_in)

        application_form = create(:application_form, :minimum_info)

        application_form.update!(phone_number: 111111)

        expect(GeocodeApplicationAddressWorker).not_to have_received(:perform_in).with(application_form.id)
      end

      it 'clears existing coordinates if address changed to international' do
        allow(GeocodeApplicationAddressWorker).to receive(:perform_in)

        application_form = create(:application_form, :minimum_info, latitude: 1.5, longitude: 0.2)

        application_form.update!(address_type: :international)

        expect([application_form.latitude, application_form.longitude]).to eq [nil, nil]
        expect(GeocodeApplicationAddressWorker).not_to have_received(:perform_in)
      end
    end
  end

  describe '#qualifications_enic_reasons_waiting_or_maybe?' do
    it 'returns true if 1 or more qualifications have an enic_reason of waiting or maybe' do
      application_form = create(:application_form)
      create(:degree_qualification, enic_reference: '12345', institution_country: 'GB', enic_reason: 'waiting', application_form: application_form)

      expect(application_form.qualifications_enic_reasons_waiting_or_maybe?).to be(true)
    end

    it 'returns false if no qualifications have an enic_reason of waiting or maybe' do
      application_form = create(:application_form)
      create(:degree_qualification, enic_reference: '12345', institution_country: 'GB', enic_reason: 'not_needed', application_form: application_form)

      expect(application_form.qualifications_enic_reasons_waiting_or_maybe?).to be(false)
    end
  end

  describe '#any_qualification_enic_reason_not_needed?' do
    it 'returns true if ALL qualifications have an enic_reason of not_needed' do
      application_form = create(:application_form)
      create(:degree_qualification, enic_reference: '12345', institution_country: 'GB', enic_reason: 'not_needed', application_form: application_form)
      create(:degree_qualification, enic_reference: '12346', institution_country: 'GB', enic_reason: 'not_needed', application_form: application_form)
      create(:degree_qualification, enic_reference: '12347', institution_country: 'GB', enic_reason: 'not_needed', application_form: application_form)

      expect(application_form.any_qualification_enic_reason_not_needed?).to be(true)
    end

    it 'returns false if any qualification has an enic_reason that is not_needed' do
      application_form = create(:application_form)
      create(:degree_qualification, enic_reference: '12345', institution_country: 'GB', enic_reason: 'not_needed', application_form: application_form)
      create(:degree_qualification, enic_reference: '12348', institution_country: 'GB', enic_reason: 'obtained', application_form: application_form)

      expect(application_form.qualifications_enic_reasons_waiting_or_maybe?).to be(false)
    end
  end

  describe '#missing_enic_reference_for_non_uk_qualifications?' do
    it 'returns false if there are no application_qualifications which are non_uk and have no enic_reference' do
      application_form = create(:application_form)
      create(:degree_qualification, enic_reference: '12345', institution_country: 'GB', application_form: application_form)

      expect(application_form.missing_enic_reference_for_non_uk_qualifications?).to be(false)
    end

    it 'returns true if there are application_qualifications which are non_uk and have no enic_reference' do
      application_form = create(:application_form)
      create(:degree_qualification, enic_reference: nil, institution_country: 'FR', application_form: application_form)

      expect(application_form.missing_enic_reference_for_non_uk_qualifications?).to be(true)
    end
  end

  describe '#previous_application_form' do
    it 'refers to the previous application' do
      previous_application_form = create(:application_form)
      application_form = create(:application_form, previous_application_form_id: previous_application_form.id)

      expect(application_form.previous_application_form).to eql(previous_application_form)
      expect(application_form.previous_application_form.subsequent_application_form).to eql(application_form)
    end
  end

  describe '#number_of_slots_left' do
    it 'returns the number of choices that a candidate can make in Apply' do
      application_form = create(:application_form)

      expect(application_form.reload.number_of_slots_left).to eq(4)

      create(:application_choice, application_form:)

      expect(application_form.reload.number_of_slots_left).to eq(3)

      create(:application_choice, application_form:)

      expect(application_form.reload.number_of_slots_left).to eq(2)

      create(:application_choice, application_form:)

      expect(application_form.reload.number_of_slots_left).to eq(1)

      create(:application_choice, application_form:)

      expect(application_form.reload.number_of_slots_left).to eq(0)
    end
  end

  describe 'auditing', :with_audited do
    it 'records an audit entry when creating a new ApplicationForm' do
      application_form = create(:application_form)
      expect(application_form.audits.count).to eq 1
    end

    it 'can view audit records for ApplicationForm and its associated ApplicationChoices' do
      application_form = create(:completed_application_form, application_choices_count: 1)

      expect {
        application_form.application_choices.first.update!(rejection_reason: 'rejected')
      }.to change { application_form.own_and_associated_audits.count }.by(1)
    end
  end

  describe '#science_gcse_needed?' do
    context 'when a candidate has no course choices' do
      it 'returns false' do
        application_form = build(:application_form)

        expect(application_form.science_gcse_needed?).to be(false)
      end
    end

    context 'when a candidate has a course choice that is primary' do
      it 'returns true' do
        application_form = application_form_with_course_option_for_provider_with(level: 'primary')

        expect(application_form.science_gcse_needed?).to be(true)
      end
    end

    context 'when a candidate has a course choice that is secondary' do
      it 'returns false' do
        application_form = application_form_with_course_option_for_provider_with(level: 'secondary')

        expect(application_form.science_gcse_needed?).to be(false)
      end
    end

    context 'when a candidate has a course choice that is further education' do
      it 'returns false' do
        application_form = application_form_with_course_option_for_provider_with(level: 'further_education')

        expect(application_form.science_gcse_needed?).to be(false)
      end
    end

    def application_form_with_course_option_for_provider_with(level:)
      provider = build(:provider)
      course = create(:course, level:, provider:)
      site = create(:site, provider:)
      course_option = create(:course_option, course:, site:)
      application_form = create(:application_form)

      create(
        :application_choice,
        application_form:,
        course_option:,
      )

      application_form
    end
  end

  describe '#blank_application?' do
    context 'when a candidate has not made any alterations to their application' do
      it 'returns true' do
        application_form = create(:application_form)
        expect(application_form.blank_application?).to be_truthy
      end
    end

    context 'when a candidate has amended their application' do
      it 'returns false' do
        application_form = create(:application_form)
        advance_time
        create(:application_work_experience, experienceable: application_form)
        expect(application_form.blank_application?).to be_falsey
      end
    end
  end

  describe '#ended_without_success?' do
    context 'with one rejected application' do
      it 'returns true' do
        application_form = described_class.new
        application_form.application_choices.build status: 'rejected'
        expect(application_form.ended_without_success?).to be true
      end
    end

    context 'with one offered application' do
      it 'returns false' do
        application_form = described_class.new
        application_form.application_choices.build status: 'offer'
        expect(application_form.ended_without_success?).to be false
      end
    end

    context 'with one rejected and one in progress application' do
      it 'returns false' do
        application_form = described_class.new
        application_form.application_choices.build status: 'rejected'
        application_form.application_choices.build status: 'awaiting_provider_decision'
        expect(application_form.ended_without_success?).to be false
      end
    end

    context 'with one rejected and one withdrawn application' do
      it 'returns true' do
        application_form = described_class.new
        application_form.application_choices.build status: 'rejected'
        application_form.application_choices.build status: 'withdrawn'
        expect(application_form.ended_without_success?).to be true
      end
    end
  end

  describe '#selected_incorrect_number_of_references?' do
    it 'is true when < 2 selections' do
      application_form = create(:application_form)
      create(:selected_reference, application_form:)

      expect(application_form.selected_incorrect_number_of_references?).to be true
    end

    it 'is true when > 2 selections' do
      application_form = create(:application_form)
      create(:selected_reference, application_form:)
      create(:selected_reference, application_form:)
      create(:selected_reference, application_form:)

      expect(application_form.selected_incorrect_number_of_references?).to be true
    end

    it 'is false when 2 selections' do
      application_form = create(:application_form)
      create(:selected_reference, application_form:)
      create(:selected_reference, application_form:)

      expect(application_form.selected_incorrect_number_of_references?).to be false
    end
  end

  describe '#equality_and_diversity_answers_provided?' do
    context 'when minimal expected attributes are present' do
      it 'is true' do
        minimum_equality_and_diversity_data = {
          sex: 'female',
          ethnic_group: 'Prefer not to say',
          disabilities: %w[Blind Deaf],
        }
        application_form = build(:application_form, equality_and_diversity: minimum_equality_and_diversity_data)
        expect(application_form.equality_and_diversity_answers_provided?).to be true
      end
    end

    context 'when minimal expected attributes are not present' do
      it 'is false' do
        application_form = build(:completed_application_form)
        application_form.equality_and_diversity = { 'sex' => 'male' }

        expect(application_form.equality_and_diversity_answers_provided?).to be false
      end
    end

    context 'when no attributes are present' do
      it 'is false' do
        application_form = build(:completed_application_form)
        application_form.equality_and_diversity = nil

        expect(application_form.equality_and_diversity_answers_provided?).to be false
      end
    end
  end

  describe '#british_or_irish?' do
    context 'when any applicant nationality is identified as "English-speaking"' do
      let(:nationality_permutations) do
        [
          { first_nationality: 'British', second_nationality: 'Pakistani' },
          { first_nationality: 'Pakistani', second_nationality: 'British' },
          { first_nationality: 'British', second_nationality: nil },
          { first_nationality: 'Irish', second_nationality: 'Pakistani' },
          { first_nationality: 'Pakistani', second_nationality: 'Irish' },
          { first_nationality: 'Irish', second_nationality: nil },
          { first_nationality: 'Iranian', second_nationality: 'Pakistani', third_nationality: 'Irish' },
        ]
      end

      it 'returns true' do
        nationality_permutations.each do |permutation|
          application_form = build(:application_form, permutation)
          expect(application_form.british_or_irish?).to be true
        end
      end
    end

    context 'when no applicant nationality is identified as "English-speaking"' do
      let(:nationality_permutations) do
        [
          { first_nationality: 'Pakistani', second_nationality: nil },
          { first_nationality: 'Chinese', second_nationality: 'Pakistani' },
          { first_nationality: 'Chinese', second_nationality: 'Pakistani', third_nationality: 'Jamaican' },
        ]
      end

      it 'return false' do
        nationality_permutations.each do |permutation|
          application_form = build(:application_form, permutation)
          expect(application_form.british_or_irish?).to be false
        end
      end
    end
  end

  describe '#nationalities' do
    it 'returns the candidates nationalities in an array' do
      application_form = build_stubbed(:application_form,
                                       first_nationality: 'British',
                                       second_nationality: 'Irish',
                                       third_nationality: 'Welsh',
                                       fourth_nationality: 'Northern Irish',
                                       fifth_nationality: nil)

      expect(application_form.nationalities).to contain_exactly('British', 'Irish', 'Welsh', 'Northern Irish')
    end
  end

  describe '#english_main_language' do
    context 'when fetch_database_value is set to true' do
      it 'returns whatever is in the database field' do
        [nil, true, false].each do |db_value|
          application_form = build(:application_form, english_main_language: db_value)
          expect(
            application_form.english_main_language(fetch_database_value: true),
          ).to eq db_value
        end
      end
    end

    context 'database value is nil' do
      let(:application_form) { build(:application_form, english_main_language: nil) }

      it 'returns false by default' do
        expect(application_form.english_main_language).to be false
      end

      context 'when british_or_irish? is true' do
        it 'returns true' do
          application_form.first_nationality = 'British'

          expect(application_form.english_main_language).to be true
        end
      end

      context 'when the english_proficiency record declares that a qualification is not needed' do
        it 'returns true' do
          english_proficiency = build(:english_proficiency, :qualification_not_needed)
          application_form.english_proficiency = english_proficiency

          expect(application_form.english_main_language).to be true
        end
      end
    end

    context 'database value is true' do
      let(:application_form) { build(:application_form, english_main_language: true) }

      it 'returns true' do
        expect(application_form.english_main_language).to be true
      end
    end

    context 'database value is false' do
      let(:application_form) { build(:application_form, english_main_language: false) }

      it 'returns false' do
        expect(application_form.english_main_language).to be false
      end
    end
  end

  describe '#international_applicant?' do
    let(:application_with_english_speaking_nationality) do
      build_stubbed(:application_form, first_nationality: 'British', second_nationality: 'French')
    end

    let(:application_with_no_english_speaking_nationalities) do
      build_stubbed(:application_form, first_nationality: 'Jamaican', second_nationality: 'Chinese')
    end

    context 'at least one selected nationality is considered "English-speaking"' do
      let(:application_form) { application_with_english_speaking_nationality }

      it 'returns false' do
        expect(application_form.international_applicant?).to be false
      end
    end

    context 'no "English-speaking" nationalities selected' do
      let(:application_form) { application_with_no_english_speaking_nationalities }

      it 'returns true' do
        expect(application_form.international_applicant?).to be true
      end
    end

    context 'nationalities not selected' do
      let(:application_form) { build_stubbed(:application_form) }

      it 'returns false' do
        expect(application_form.international_applicant?).to be false
      end
    end
  end

  describe '#full_address' do
    it 'returns the candidate address and postcode for UK addresses' do
      application_form = create(
        :completed_application_form,
        address_line1: 'Flat 4 Prospect House',
        address_line2: 'Technique Street',
        address_line3: 'Crynant',
        address_line4: 'West Glamorgan',
        postcode: 'NW1 8TQ',
      )

      expect(application_form.full_address).to eq [
        'Flat 4 Prospect House',
        'Technique Street',
        'Crynant',
        'West Glamorgan',
        'NW1 8TQ',
      ]
    end

    it 'renders the candidate address for international addresses' do
      application_form = build_stubbed(
        :completed_application_form,
        :international_address,
        address_line1: 'Beverley Hills',
        address_line3: nil,
        address_line4: '90210',
        postcode: nil,
        country: 'US',
      )

      expect(application_form.full_address).to eq ['Beverley Hills', '90210', 'United States']
    end
  end

  describe '#domicile' do
    it 'calls #hesa_code_for_country for international addresses' do
      application_form = build_stubbed(:completed_application_form, :international_address)
      allow(DomicileResolver).to receive(:hesa_code_for_country)
                                 .with(application_form.country).and_return(':)')

      expect(application_form.domicile).to eq(':)')
    end

    it 'calls #hesa_code_for_postcode for UK addresses' do
      application_form = create(:completed_application_form)
      allow(DomicileResolver).to receive(:hesa_code_for_postcode)
                                 .with(application_form.postcode).and_return(':)')

      expect(application_form.domicile).to eq(':)')
    end
  end

  describe '#any_offer_accepted?' do
    it 'returns false if there is no accepted offer on any of the application choices' do
      offer_choice = create(:application_choice, :offered)
      other_choice = create(:application_choice, :withdrawn)
      application_form = create(:completed_application_form, application_choices: [offer_choice, other_choice])
      expect(application_form.any_offer_accepted?).to be(false)
    end

    it 'returns false if there is no accepted offer and there is conditions not met on any of the application choices' do
      offer_choice = create(:application_choice, :offered)
      other_choice = create(:application_choice, :withdrawn)
      another_choice = create(:application_choice, :conditions_not_met)
      application_form = create(:completed_application_form, application_choices: [offer_choice, other_choice, another_choice])
      expect(application_form.any_offer_accepted?).to be(false)
    end

    it 'returns true if there is an application choice with an accepted offer' do
      accepted_offer_choice = create(:application_choice, :accepted)
      other_choice = create(:application_choice, :rejected)
      application_form = create(:completed_application_form, application_choices: [accepted_offer_choice, other_choice])
      expect(application_form.any_offer_accepted?).to be(true)
    end
  end

  describe '#all_provider_decisions_made?' do
    it 'returns false if the application choices are in awaiting provider decision state' do
      application_choice = create(:application_choice, :awaiting_provider_decision)
      application_form = create(:completed_application_form, application_choices: [application_choice])
      expect(application_form.all_provider_decisions_made?).to be(false)
    end

    it 'returns true if the application choices are not in awaiting provider decision state' do
      application_choice = create(:application_choice, :offered)
      application_form = create(:completed_application_form, application_choices: [application_choice])
      expect(application_form.all_provider_decisions_made?).to be(true)
    end
  end

  describe '#carry_over?' do
    context 'application is unsubmitted' do
      let(:unsubmitted_application_form) do
        build(:application_form, :unsubmitted, application_choices: [build(:application_choice)])
      end

      it 'true when application deadline has passed' do
        travel_temporarily_to(unsubmitted_application_form.apply_deadline_at + 1.second) do
          expect(unsubmitted_application_form.carry_over?).to be(true)
        end
      end

      it 'false when application deadline has not passed' do
        travel_temporarily_to(unsubmitted_application_form.apply_deadline_at - 1.second) do
          expect(unsubmitted_application_form.carry_over?).to be(false)
        end
      end
    end

    context 'application does not have application choices' do
      let(:no_choices_application_form) { build(:application_form, :submitted, application_choices: []) }

      it 'true when application deadline has passed' do
        travel_temporarily_to(no_choices_application_form.apply_deadline_at + 1.second) do
          expect(no_choices_application_form.carry_over?).to be(true)
        end
      end

      it 'false when application deadline has not passed' do
        travel_temporarily_to(no_choices_application_form.apply_deadline_at - 1.second) do
          expect(no_choices_application_form.carry_over?).to be(false)
        end
      end
    end

    context 'an application choice is awaiting candidate decision' do
      let(:submitted_application_form) do
        build(:application_form, :submitted, application_choices: [build(:application_choice, :offered)])
      end

      it 'returns false after the application deadline has passed' do
        travel_temporarily_to(submitted_application_form.apply_deadline_at + 1.second) do
          expect(submitted_application_form.carry_over?).to be(false)
        end
      end
    end

    context 'an application choice is awaiting provider decision' do
      it 'returns false after the application deadline has passed', :aggregate_failures do
        %i[awaiting_provider_decision interviewing inactive].each do |awaiting_decision_status|
          application_form = build(
            :application_form,
            :submitted,
            application_choices: [build(:application_choice, awaiting_decision_status)],
          )
          travel_temporarily_to(application_form.apply_deadline_at + 1.second) do
            expect(application_form.carry_over?).to be(false)
          end
        end
      end
    end
  end

  describe '#unsucessful_and_apply_deadline_has_passed?' do
    context 'application ended with success' do
      it 'returns false' do
        application_choice = build(:application_choice, :offered)
        application_form = build(:application_form, application_choices: [application_choice])
        travel_temporarily_to(application_form.apply_deadline_at) do
          expect(application_form.unsuccessful_and_apply_deadline_has_passed?).to be(false)
        end
      end
    end

    context 'application ended without success and apply deadline has passed' do
      it 'returns true' do
        application_choice = build(:application_choice, :rejected)
        application_form = build(:application_form, application_choices: [application_choice])
        travel_temporarily_to(application_form.apply_deadline_at + 1.second) do
          expect(application_form.unsuccessful_and_apply_deadline_has_passed?).to be(true)
        end
      end
    end

    context 'application ended without success and apply deadline has not passed' do
      it 'returns false' do
        application_choice = build(:application_choice, :rejected)
        application_form = build(:application_form, application_choices: [application_choice])
        travel_temporarily_to(application_form.apply_deadline_at - 1.second) do
          expect(application_form.unsuccessful_and_apply_deadline_has_passed?).to be(false)
        end
      end
    end
  end

  describe '#no_degree_and_degree_not_completed?' do
    context 'when there are no degrees and the degree is not completed' do
      let(:application_form) { create(:application_form, degrees_completed: false) }

      it 'returns true' do
        expect(application_form.no_degree_and_degree_not_completed?).to be true
      end
    end

    context 'when there are degrees or the degree is completed' do
      let(:application_form_with_degrees) { create(:application_form, :with_degree, degrees_completed: false) }
      let(:application_form_completed) { create(:application_form, degrees_completed: true) }

      it 'returns false if degrees exist' do
        expect(application_form_with_degrees.no_degree_and_degree_not_completed?).to be false
      end

      it 'returns false if degree is completed' do
        expect(application_form_completed.no_degree_and_degree_not_completed?).to be false
      end
    end
  end

  describe '#no_degree_and_degree_completed?' do
    context 'when there are no degrees and the degree is completed' do
      let(:application_form) { create(:application_form, degrees_completed: true) }

      it 'returns true' do
        expect(application_form.no_degree_and_degree_completed?).to be true
      end
    end

    context 'when there are degrees' do
      let(:application_form_with_degrees) { create(:application_form, :with_degree, degrees_completed: true) }

      it 'returns false if degrees exist' do
        expect(application_form_with_degrees.no_degree_and_degree_completed?).to be false
      end
    end

    context 'when there no degree the degree is not completed' do
      let(:application_form_not_completed) { create(:application_form, degrees_completed: false) }

      it 'returns false if degree is not completed' do
        expect(application_form_not_completed.no_degree_and_degree_completed?).to be false
      end
    end
  end

  describe '#no_degrees?' do
    context 'when there are no degrees' do
      let(:application_form) { create(:application_form) }

      it 'returns true' do
        expect(application_form.no_degrees?).to be true
      end
    end

    context 'when there are degrees' do
      let(:application_form_with_degrees) { create(:application_form, :with_degree) }

      it 'returns false' do
        expect(application_form_with_degrees.no_degrees?).to be false
      end
    end
  end

  describe '#degrees?' do
    context 'when there are degrees' do
      let(:application_form_with_degrees) { create(:application_form, :with_degree) }

      it 'returns true' do
        expect(application_form_with_degrees.degrees?).to be true
      end
    end

    context 'when there are no degrees' do
      let(:application_form) { create(:application_form) }

      it 'returns false' do
        expect(application_form.degrees?).to be false
      end
    end
  end

  describe '#qualifications_completed?' do
    context 'when `degrees_completed` is false' do
      let(:application_form) do
        build(
          :application_form,
          degrees_completed: false,
          maths_gcse_completed: true,
          english_gcse_completed: true,
          science_gcse_completed: true,
        )
      end

      it 'returns false' do
        expect(application_form.qualifications_completed?).to be(false)
      end
    end

    context 'when `science_gcse_completed` is false but science GCSE is not needed' do
      let(:application_form) do
        build(
          :application_form,
          degrees_completed: true,
          maths_gcse_completed: true,
          english_gcse_completed: true,
          science_gcse_completed: false,
        )
      end

      it 'returns true' do
        allow(application_form).to receive(:science_gcse_needed?).and_return(false)
        expect(application_form.qualifications_completed?).to be(true)
      end
    end

    context 'when `science_gcse_completed` is false and science GCSE is needed' do
      let(:application_form) do
        build(
          :application_form,
          degrees_completed: true,
          maths_gcse_completed: true,
          english_gcse_completed: true,
          science_gcse_completed: false,
        )
      end

      it 'returns false' do
        allow(application_form).to receive(:science_gcse_needed?).and_return(true)
        expect(application_form.qualifications_completed?).to be(false)
      end
    end

    context 'when english_gcse_completed is false' do
      let(:application_form) do
        build(
          :application_form,
          degrees_completed: true,
          maths_gcse_completed: true,
          english_gcse_completed: false,
          science_gcse_completed: true,
        )
      end

      it 'returns false' do
        expect(application_form.qualifications_completed?).to be(false)
      end
    end

    context 'when all flags are true' do
      let(:application_form) do
        build(
          :application_form,
          degrees_completed: true,
          maths_gcse_completed: true,
          english_gcse_completed: true,
          science_gcse_completed: true,
        )
      end

      it 'when all flags are true' do
        expect(application_form.qualifications_completed?).to be(true)
      end
    end
  end

  describe '#contains_course?' do
    let(:application_form) { create(:application_form) }
    let(:course) { create(:course) }
    let(:course_option_applied) { build(:course_option, course:) }
    let(:course_option_not_applied) { build(:course_option, course:) }

    context 'when the candidate cannot reapply for it' do
      (ApplicationStateChange.valid_states - ApplicationStateChange.reapply_states).each do |status|
        it "returns true when status is #{status}" do
          create(:application_choice, status.to_sym, course_option: course_option_applied, application_form:)
          expect(application_form.contains_course?(course)).to be true
        end
      end
    end

    context 'when the candidate can reapply for it' do
      ApplicationStateChange.reapply_states.each do |status|
        it "returns false when the states is #{status}" do
          create(:application_choice, status.to_sym, course:, application_form:)
          expect(application_form.contains_course?(course)).to be false
        end
      end
    end
  end

  describe '#complete_references_information?' do
    context 'when an applications has two or more references' do
      it 'returns true' do
        application_form = create(:application_form)
        create(:reference, application_form:)
        create(:reference, application_form:)

        expect(application_form.complete_references_information?).to be true
      end
    end

    context 'when an application has fewer than two references' do
      it 'returns false' do
        application_form = create(:application_form)
        create(:reference, application_form:)

        expect(application_form.complete_references_information?).to be false
      end
    end

    context 'when an application has zero references' do
      it 'returns false' do
        application_form = create(:application_form)

        expect(application_form.complete_references_information?).to be false
      end
    end
  end

  describe '#recruited?' do
    context 'when a candidate has been recruited' do
      it 'returns true' do
        recruited_application_choice = create(:application_choice, :recruited)
        other_choice = create(:application_choice, :rejected)
        application_form = create(:completed_application_form, application_choices: [recruited_application_choice, other_choice])
        expect(application_form).to be_recruited
      end
    end

    context 'when a candidate has not yet met conditions' do
      it 'returns false' do
        application_choice_accepted = create(:application_choice, :accepted)
        other_choice = create(:application_choice, :rejected)
        application_form = create(:completed_application_form, application_choices: [application_choice_accepted, other_choice])
        expect(application_form).not_to be_recruited
      end
    end
  end

  describe '#ask_about_free_school_meals?' do
    context 'when a candidate is British and born on or after 1 September 1964' do
      it 'returns true' do
        application_form = create(:application_form, first_nationality: 'British', date_of_birth: described_class::BEGINNING_OF_FREE_SCHOOL_MEALS)

        expect(application_form.ask_about_free_school_meals?).to be true
      end
    end

    context 'when a candidate is Irish and born on or after 1 September 1964' do
      it 'returns true' do
        application_form = create(:application_form, second_nationality: 'Irish', date_of_birth: Date.new(1999, 10, 1))

        expect(application_form.ask_about_free_school_meals?).to be true
      end
    end

    context 'when a candidate is born before 1 September 1964' do
      it 'returns false' do
        application_form = create(:application_form, first_nationality: 'British', date_of_birth: Date.new(1954, 9, 1))

        expect(application_form.ask_about_free_school_meals?).to be false
      end
    end

    context 'when a candidate is not British or Irish' do
      it 'returns false' do
        application_form = create(:application_form, first_nationality: 'American', second_nationality: 'French', date_of_birth: described_class::BEGINNING_OF_FREE_SCHOOL_MEALS)

        expect(application_form.ask_about_free_school_meals?).to be false
      end
    end
  end

  describe 'section completed fields' do
    let(:form) { build(:application_form) }

    it 'sets the associated timestamp if the boolean is being set to `true`' do
      described_class::SECTION_COMPLETED_FIELDS.each do |field|
        form.public_send("#{field}_completed_at=", 2.days.ago)
        form.public_send("#{field}_completed=", true)
        expect(form.public_send("#{field}_completed_at")).to eq(Time.zone.now)
      end
    end

    it 'nulls out the associated timestamp if the boolean is being set to `false`' do
      described_class::SECTION_COMPLETED_FIELDS.each do |field|
        form.public_send("#{field}_completed_at=", 2.days.ago)
        form.public_send("#{field}_completed=", false)
        expect(form.public_send("#{field}_completed_at")).to be_nil
      end
    end
  end

  describe '#after_apply_deadline?' do
    let(:form) { build(:application_form, recruitment_cycle_timetable: current_timetable) }

    it 'returns false before the deadline' do
      travel_temporarily_to(current_timetable.apply_deadline_at - 1.minute) do
        expect(form.after_apply_deadline?).to be false
      end
    end

    it 'returns true after the deadline while still in current cycle' do
      travel_temporarily_to(current_timetable.apply_deadline_at + 1.minute) do
        expect(form.after_apply_deadline?).to be true
      end
    end

    it 'returns true if a new cycle has started' do
      next_timetable = form.recruitment_cycle_timetable.relative_next_timetable
      travel_temporarily_to(next_timetable.apply_deadline_at - 1.minute) do
        expect(form.after_apply_deadline?).to be true
      end
    end
  end

  describe '#can_add_course_choice?' do
    context 'not current cycle' do
      it 'returns false if in next cycle' do
        application_form = build(:application_form, recruitment_cycle_year: current_year)
        travel_temporarily_to(next_timetable.find_opens_at + 1.second) do
          expect(application_form.can_add_course_choice?).to be false
        end
      end

      it 'returns false if in previous cycle' do
        application_form = build(:application_form, recruitment_cycle_year: current_year)
        travel_temporarily_to(previous_timetable.find_opens_at + 1.second) do
          expect(application_form.can_add_course_choice?).to be false
        end
      end
    end

    context 'current cycle' do
      it 'return false if after apply deadline' do
        application_form = build(:application_form)
        travel_temporarily_to(application_form.apply_deadline_at + 1.second) do
          expect(application_form.can_add_course_choice?).to be false
        end
      end

      it 'returns true if before apply deadline' do
        application_form = build(:application_form)
        travel_temporarily_to(application_form.apply_deadline_at - 1.second) do
          expect(application_form.can_add_course_choice?).to be true
        end
      end
    end
  end

  describe '#can_submit' do
    context 'not current cycle' do
      it 'returns false' do
        application_form = build(:application_form, recruitment_cycle_year: current_year)
        travel_temporarily_to(next_timetable.find_opens_at + 1.second) do
          expect(application_form.can_submit?).to be false
        end
      end
    end

    context 'current cycle' do
      it 'returns false before apply opens' do
        application_form = build(:application_form)
        travel_temporarily_to(application_form.apply_opens_at - 1.second) do
          expect(application_form.can_submit?).to be false
        end
      end

      it 'returns false after apply deadline' do
        application_form = build(:application_form)
        travel_temporarily_to(application_form.apply_deadline_at + 1.second) do
          expect(application_form.can_submit?).to be false
        end
      end

      it 'returns true mid cycle' do
        application_form = build(:application_form)
        travel_temporarily_to(application_form.apply_opens_at + 1.second) do
          expect(application_form.can_submit?).to be true
        end
      end
    end
  end

  describe '#redacted_full_name' do
    it 'returns the full name redacted' do
      first_name = 'First'
      last_name = 'Last'
      application_form = build(:application_form, first_name:, last_name:)

      expect(application_form.redacted_full_name).to eq('F***** L*****')
    end
  end

  describe '#eligible_and_unassigned_a_teaching_training_adviser?' do
    it 'returns true when the validation is valid' do
      application_form = build(:application_form)
      allow(Adviser::ApplicationFormValidations).to receive(:new)
                                                .with(application_form)
                                                .and_return(instance_double(Adviser::ApplicationFormValidations, valid?: true))

      expect(application_form.eligible_and_unassigned_a_teaching_training_adviser?).to be true
    end

    it 'returns false when the validation is invalid' do
      application_form = build(:application_form)
      allow(Adviser::ApplicationFormValidations).to receive(:new)
                                                      .with(application_form)
                                                      .and_return(instance_double(Adviser::ApplicationFormValidations, valid?: false))

      expect(application_form.eligible_and_unassigned_a_teaching_training_adviser?).to be false
    end
  end

  describe '#eligible_to_sign_up_for_a_teaching_training_adviser?' do
    before do
      allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache.lookup_store(:memory_store))
      Rails.cache.clear
      Sidekiq::Worker.clear_all
    end

    subject(:application_form) { build_stubbed(:application_form) }

    context 'when the application form is eligible' do
      before do
        validation_double = instance_double(Adviser::ApplicationFormValidations, valid?: true)
        allow(Adviser::ApplicationFormValidations).to receive(:new).and_return(validation_double)
      end

      it { is_expected.to be_eligible_to_sign_up_for_a_teaching_training_adviser }
    end

    context 'when the application form is not eligible' do
      before do
        validation_double = instance_double(Adviser::ApplicationFormValidations, valid?: false)
        allow(Adviser::ApplicationFormValidations).to receive(:new).and_return(validation_double)
      end

      it { is_expected.not_to be_eligible_to_sign_up_for_a_teaching_training_adviser }
    end

    context 'refreshing the adviser status' do
      it 'queues the refresh worker' do
        expect {
          application_form.eligible_to_sign_up_for_a_teaching_training_adviser?
        }.to change(Adviser::RefreshAdviserStatusWorker.jobs, :size).from(0).to(1)
      end

      it 'does not queue the refresh worker if it has been refreshed recently' do
        application_form.eligible_to_sign_up_for_a_teaching_training_adviser?

        expect {
          application_form.eligible_to_sign_up_for_a_teaching_training_adviser?
        }.not_to change(Adviser::RefreshAdviserStatusWorker.jobs, :size)
      end
    end
  end

  describe '#already_assigned_to_an_adviser?' do
    before do
      allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache.lookup_store(:memory_store))
      Rails.cache.clear
      Sidekiq::Worker.clear_all
    end

    context 'when the application form is assigned to an adviser' do
      subject(:application_form) { build_stubbed(:application_form, adviser_status: 'assigned') }

      it { is_expected.to be_already_assigned_to_an_adviser }
    end

    context 'when the application form is previously assigned to an adviser' do
      subject(:application_form) { build_stubbed(:application_form, adviser_status: 'previously_assigned') }

      it { is_expected.to be_already_assigned_to_an_adviser }
    end

    context 'when the application form is unassigned to an adviser' do
      subject(:application_form) { build_stubbed(:application_form, adviser_status: 'unassigned') }

      it { is_expected.not_to be_already_assigned_to_an_adviser }
    end

    context 'when the application form is waiting to be assigned to an adviser' do
      subject(:application_form) { build_stubbed(:application_form, adviser_status: 'waiting_to_be_assigned') }

      it { is_expected.not_to be_already_assigned_to_an_adviser }
    end

    context 'refreshing the adviser status' do
      subject(:application_form) { build_stubbed(:application_form) }

      it 'queues the refresh worker' do
        expect {
          application_form.already_assigned_to_an_adviser?
        }.to change(Adviser::RefreshAdviserStatusWorker.jobs, :size).from(0).to(1)
      end

      it 'does not queue the refresh worker if it has been refreshed recently' do
        application_form.already_assigned_to_an_adviser?

        expect {
          application_form.already_assigned_to_an_adviser?
        }.not_to change(Adviser::RefreshAdviserStatusWorker.jobs, :size)
      end
    end
  end

  describe '#waiting_to_be_assigned_to_an_adviser?' do
    before do
      allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache.lookup_store(:memory_store))
      Rails.cache.clear
      Sidekiq::Worker.clear_all
    end

    context 'when the application form is assigned to an adviser' do
      subject(:application_form) { build_stubbed(:application_form, adviser_status: 'assigned') }

      it { is_expected.not_to be_waiting_to_be_assigned_to_an_adviser }
    end

    context 'when the application form is previously assigned to an adviser' do
      subject(:application_form) { build_stubbed(:application_form, adviser_status: 'previously_assigned') }

      it { is_expected.not_to be_waiting_to_be_assigned_to_an_adviser }
    end

    context 'when the application form is unassigned to an adviser' do
      subject(:application_form) { build_stubbed(:application_form, adviser_status: 'unassigned') }

      it { is_expected.not_to be_waiting_to_be_assigned_to_an_adviser }
    end

    context 'when the application form is waiting to be assigned to an adviser' do
      subject(:application_form) { build_stubbed(:application_form, adviser_status: 'waiting_to_be_assigned') }

      it { is_expected.to be_waiting_to_be_assigned_to_an_adviser }
    end

    context 'refreshing the adviser status' do
      subject(:application_form) { build_stubbed(:application_form) }

      it 'queues the refresh worker' do
        expect {
          application_form.waiting_to_be_assigned_to_an_adviser?
        }.to change(Adviser::RefreshAdviserStatusWorker.jobs, :size).from(0).to(1)
      end

      it 'does not queue the refresh worker if it has been refreshed recently' do
        application_form.waiting_to_be_assigned_to_an_adviser?

        expect {
          application_form.waiting_to_be_assigned_to_an_adviser?
        }.not_to change(Adviser::RefreshAdviserStatusWorker.jobs, :size)
      end
    end
  end

  describe '#applicable_degree_for_adviser' do
    let(:application_form) { create(:application_form) }

    it 'returns nil when there are no qualifications' do
      expect(application_form.applicable_degree_for_adviser).to be_nil
    end

    it 'excludes non-degree type qualifications' do
      create(:gcse_qualification, application_form:)
      create(:other_qualification, application_form:)

      expect(application_form.applicable_degree_for_adviser).to be_nil
    end

    it 'excludes incomplete degrees' do
      create(:degree_qualification,
             :adviser_sign_up_applicable,
             :incomplete,
             application_form:)

      expect(application_form.applicable_degree_for_adviser).to be_nil
    end

    it 'excludes international degrees without equivalency details' do
      create(:non_uk_degree_qualification,
             :adviser_sign_up_applicable,
             enic_reference: nil,
             application_form:)

      expect(application_form.applicable_degree_for_adviser).to be_nil
    end

    it 'excludes domestic degrees do not meet the minimum grade requirements' do
      create(:degree_qualification,
             :adviser_sign_up_applicable,
             grade: 'Third-class honours',
             application_form:)

      expect(application_form.applicable_degree_for_adviser).to be_nil
    end

    it 'excludes degrees that are not an applicable level' do
      create(:degree_qualification,
             :adviser_sign_up_applicable,
             qualification_level: 'foundation',
             application_form:)

      create(:non_uk_degree_qualification,
             :adviser_sign_up_applicable,
             comparable_uk_degree: 'bachelor_ordinary_degree',
             application_form:)

      expect(application_form.applicable_degree_for_adviser).to be_nil
    end

    it 'returns an applicable domestic degree, favouring the degree with the highest grade' do
      create(:degree_qualification,
             :adviser_sign_up_applicable,
             application_form:,
             grade: 'Upper second-class honours (2:1)')

      first_class_domestic_degree = create(:degree_qualification,
                                           :adviser_sign_up_applicable,
                                           application_form:,
                                           grade: 'First-class honours')

      expect(application_form.applicable_degree_for_adviser).to eq(first_class_domestic_degree)
    end

    it 'returns an applicable international degree' do
      applicable_international_degree = create(:non_uk_degree_qualification,
                                               :adviser_sign_up_applicable,
                                               application_form:)

      expect(application_form.applicable_degree_for_adviser).to eq(applicable_international_degree)
    end

    it 'returns a domestic degree if there are international degrees as well' do
      first_class_domestic_degree = create(:degree_qualification,
                                           :adviser_sign_up_applicable,
                                           application_form:,
                                           grade: 'First-class honours')

      create(:non_uk_degree_qualification,
             :adviser_sign_up_applicable,
             application_form:)

      expect(application_form.applicable_degree_for_adviser).to eq(first_class_domestic_degree)
    end
  end

  describe '#requires_visa_sponsorship?' do
    it 'is true if candidates has indicated they require visa sponsorship' do
      application_form = build_stubbed(:application_form, right_to_work_or_study: 'no')

      expect(application_form.requires_visa_sponsorship?).to be true
    end

    it 'is true if candidate has a skilled worker or student visa' do
      student_application_form = build_stubbed(:application_form, right_to_work_or_study: 'yes', immigration_status: 'student_visa')
      skilled_worker_application_form = build_stubbed(:application_form, right_to_work_or_study: 'yes', immigration_status: 'skilled_worker_visa')

      expect(student_application_form.requires_visa_sponsorship?).to be true
      expect(skilled_worker_application_form.requires_visa_sponsorship?).to be true
    end

    it 'is false if candidate has other kind of visa' do
      possible_statuses = described_class.immigration_statuses.reject { |status| status.in? %w[student_visa skilled_worker_visa] }
      possible_statuses.each_value do |immigration_status|
        application_form = build_stubbed(:application_form, right_to_work_or_study: 'yes', immigration_status:)
        expect(application_form.requires_visa_sponsorship?).to be false
      end
    end
  end
end
