require 'rails_helper'

RSpec.describe ProviderInterface::OfferWizard do
  subject(:wizard) do
    described_class.new(
      store,
      application_choice_id:,
      course_id:,
      course_option_id:,
      current_step:,
      decision:,
      further_condition_attrs:,
      provider_id:,
      ske_conditions:,
      standard_conditions:,
      study_mode:,
      require_references:,
      references_description:,
    )
  end

  let(:store) { instance_double(WizardStateStores::RedisStore) }
  let(:provider_id) { nil }
  let(:course_id) { nil }
  let(:require_references) { nil }
  let(:references_description) { nil }
  let(:course_option) { create(:course_option) }
  let(:course_option_id) { course_option.id }
  let(:study_mode) { nil }
  let(:application_choice_id) { create(:application_choice).id }
  let(:standard_conditions) { OfferCondition::STANDARD_CONDITIONS }
  let(:subjects) { [] }
  let(:subject_type) { 'language' }
  let(:graduation_cutoff_date) { Time.zone.now.iso8601 }
  let(:ske_conditions) do
    subjects.map { |subject| SkeCondition.new(subject:, subject_type:, graduation_cutoff_date:, length: '8') }
  end
  let(:further_condition_1) { '' }
  let(:further_condition_2) { '' }
  let(:further_condition_3) { '' }
  let(:further_condition_4) { '' }
  let(:further_conditions) do
    [
      further_condition_1,
      further_condition_2,
      further_condition_3,
      further_condition_4,
    ].compact_blank
  end
  let(:further_condition_attrs) do
    further_conditions.each_with_index.to_h do |text, index|
      [index.to_s, { 'text' => text }]
    end
  end
  let(:current_step) { nil }
  let(:decision) { nil }

  before { allow(store).to receive(:read) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:decision).on(:select_option) }
    it { is_expected.to validate_presence_of(:course_option_id).on(:locations) }
    it { is_expected.to validate_presence_of(:course_option_id).on(:save) }
    it { is_expected.to validate_presence_of(:study_mode).on(:study_modes) }
    it { is_expected.to validate_presence_of(:study_mode).on(:save) }
    it { is_expected.to validate_presence_of(:course_id).on(:courses) }
    it { is_expected.to validate_presence_of(:course_id).on(:save) }
    it { is_expected.to validate_inclusion_of(:require_references).in_array([1, 0]).on(:conditions) }

    describe 'when a ske condition is required' do
      let(:decision) { :make_offer }

      context 'when fewer than 3 SKE languages' do
        let(:current_step) { :ske_requirements }
        let(:subjects) { %w[French Spanish] }

        it 'be valid' do
          expect(wizard).to be_valid(current_step)
        end
      end

      context 'when one SKE language' do
        let(:subjects) { %w[Spanish] }

        context 'when invalid on ske reason step' do
          let(:current_step) { :ske_reason }

          it 'adds errors' do
            expect(wizard.valid?(current_step)).to be(false)
            expect(wizard.errors['ske_conditions_attributes[0][reason]']).to be_present
          end
        end
      end

      context 'when subject is language' do
        let(:application_choice) { create(:application_choice) }
        let(:course_option_id) { application_choice.course_option.id }
        let(:application_choice_id) { application_choice.id }

        before do
          application_choice.course_option.course.subjects.delete_all
          application_choice.course_option.course.subjects << build(:subject, code: '15', name: 'Portuguese')
        end

        context 'when more than 2 SKE languages' do
          let(:current_step) { :ske_requirements }
          let(:subjects) { %w[German French Spanish] }

          it 'adds the correct validation' do
            expect(wizard.valid?(current_step)).to be(false)
            expect(wizard.errors[:base]).to be_present
          end
        end

        context 'when validating languages list' do
          let(:current_step) { :ske_requirements }

          context 'when it is included in the list' do
            let(:subjects) { %w[French Spanish] }

            it { is_expected.to be_valid(current_step) }
          end

          context 'when it is not included in the list' do
            let(:subjects) { %w[Martian] }

            it 'be invalid' do
              expect(wizard).not_to be_valid(current_step)
            end
          end
        end
      end

      context 'when validating language ske reason' do
        let(:current_step) { :ske_reason }
        let(:subjects) { %w[French Spanish] }

        it 'adds error to ske condition reason' do
          expect(wizard).not_to be_valid(current_step)
          expect(wizard.errors['ske_conditions_attributes[0][reason]']).to be_present
          expect(wizard.errors['ske_conditions_attributes[1][reason]']).to be_present
        end
      end

      context 'when validating standard flow ske reason' do
        let(:current_step) { :ske_reason }
        let(:subjects) { %w[Mathematics] }
        let(:subject_type) { 'standard' }

        it 'adds error to ske condition reason' do
          expect(wizard).not_to be_valid(current_step)
          expect(wizard.errors['ske_conditions_attributes[0][reason]']).to be_present
        end
      end
    end

    context 'if a further condition is too long' do
      let(:further_condition_1) { Faker::Lorem.paragraph_by_chars(number: 300) }
      let(:further_condition_2) { Faker::Lorem.paragraph_by_chars(number: 300) }

      it 'adds the correct validation error messages to the wizard' do
        expect(wizard.valid?(:conditions)).to be(false)
        expect(wizard.errors[:'further_conditions[0][text]']).to contain_exactly('Condition 1 must be 255 characters or fewer')
        expect(wizard.errors[:'further_conditions[1][text]']).to contain_exactly('Condition 2 must be 255 characters or fewer')
        expect(wizard.errors[:'further_conditions[2][text]']).to be_blank
      end

      it 'creates custom methods with the field name that contain the error value' do
        expect(wizard.valid?(:conditions)).to be(false)
        expect(wizard.errors['further_conditions[0][text]']).to eq(['Condition 1 must be 255 characters or fewer'])
      end
    end

    context 'if the offer has too many conditions' do
      let(:further_conditions) { 22.times.map { Faker::Lorem.paragraph } }

      it 'adds the correct validation error messages to the wizard' do
        expect(wizard.valid?(:conditions)).to be(false)

        expect(wizard.errors[:base]).to contain_exactly("The offer must have #{OfferValidations::MAX_CONDITIONS_COUNT} conditions or fewer")
      end
    end

    context 'if the course option is in an invalid state' do
      let(:course_option) { create(:course_option) }
      let(:course_option_id) { course_option.id }
      let(:course_id) { course_option.course.id }
      let(:provider_id) { create(:provider).id }
      let(:study_mode) { course_option.study_mode }

      it 'throws an error' do
        expect(wizard.valid?(:save)).to be(false)
      end
    end

    context 'if require_references is true (1)' do
      let(:require_references) { 1 }

      context 'if the references_description is blank' do
        it 'adds the correct validation error messages to the wizard' do
          expect(wizard.valid?(:conditions)).to be(false)
          expect(wizard.errors[:references_description]).to contain_exactly(
            'Enter details of the specific reference you want',
          )
        end
      end
    end
  end

  describe '#initialize' do
    context 'is responsible for sanitising the attributes' do
      context 'when the provided course_id does not match the stored value' do
        let(:wizard) do
          described_class.new(store, { course_id: course_id })
        end
        let(:stored_data) { { course_id: 5, course_option_id: 3, study_mode: :full_time, provider_id: 10 }.to_json }
        let(:course_id) { 4 }

        before do
          allow(store).to receive(:read).and_return(stored_data)
        end

        it 'resets the study mode and course_option_id' do
          expect(wizard.study_mode).to be_nil
          expect(wizard.course_option_id).to be_nil
          expect(wizard.course_id).to eq(course_id)
          expect(wizard.provider_id).to eq(10)
        end
      end

      context 'when stored values does not contain a course' do
        let(:wizard) do
          described_class.new(store, { course_id: course_id })
        end
        let(:stored_data) { { course_option_id: 3, study_mode: :full_time, provider_id: 10 }.to_json }
        let(:course_id) { 5 }

        before do
          allow(store).to receive(:read).and_return(stored_data)
        end

        it 'does not reset the study mode and course_option_id' do
          expect(wizard.study_mode).to eq 'full_time'
          expect(wizard.course_option_id).to be 3
          expect(wizard.course_id).to eq(course_id)
          expect(wizard.provider_id).to eq(10)
        end
      end
    end
  end

  describe '.build_from_application_choice' do
    let(:offer) { build(:offer, conditions:) }
    let(:application_choice) { create(:application_choice, :offered, offer:) }
    let(:conditions) do
      [
        build(:text_condition, description: 'Fitness to train to teach check'),
        build(:text_condition, description: 'Be cool'),
      ]
    end
    let(:options) { {} }
    let(:wizard) do
      described_class.build_from_application_choice(
        store,
        application_choice,
        options,
      )
    end

    it 'correctly populates the wizard with offer conditions' do
      expect(wizard).to be_valid
      expect(wizard.standard_conditions).to contain_exactly('Fitness to train to teach check')
      expected_condition_id = conditions.last.id
      expect(wizard.further_condition_attrs).to eq({ '0' => { 'text' => 'Be cool', 'condition_id' => expected_condition_id } })
    end

    context 'when unchecked reference condition' do
      let(:conditions) { [build(:reference_condition, required: false)] }

      it 'correctly populates the wizard with reference condition' do
        expect(wizard).to be_valid
        expect(wizard.require_references).to be_zero
      end
    end

    context 'when checked reference condition' do
      let(:conditions) { [build(:reference_condition, required: true)] }

      it 'correctly populates the wizard with reference condition' do
        expect(wizard).to be_valid
        expect(wizard.require_references).to be(1)
      end
    end

    context 'when there is no offer present' do
      let(:application_choice) { create(:application_choice) }

      it 'populates the conditions with the standard ones' do
        expect(wizard).to be_valid
        expect(wizard.standard_conditions).to match_array(OfferCondition::STANDARD_CONDITIONS)
        expect(wizard.further_condition_attrs).to eq({})
      end
    end
  end

  describe '#next_step' do
    context 'when making an offer' do
      let(:decision) { :make_offer }

      context 'when current_step is :select_option' do
        let(:current_step) { :select_option }

        it 'returns :conditions' do
          expect(wizard.next_step).to eq(:conditions)
        end
      end

      context 'when current_step is :conditions' do
        let(:current_step) { :conditions }

        it 'returns :check' do
          expect(wizard.next_step).to eq(:check)
        end
      end

      context 'when course is undergraduate and current step is :select_option' do
        let(:current_step) { :select_option }
        let(:course) do
          create(
            :course,
            :teacher_degree_apprenticeship,
            subjects: [build(:subject, code: '15', name: 'Portuguese')],
          )
        end
        let(:application_choice) do
          create(:application_choice, course_option: create(:course_option, course:))
        end
        let(:application_choice_id) { application_choice.id }
        let(:course_option_id) { application_choice.course_option.id }

        it 'returns :conditions' do
          expect(wizard.next_step).to eq(:conditions)
        end
      end

      context 'when a ske condition is required' do
        let(:ske_conditions) { [SkeCondition.new] }

        context 'and the course is a modern language' do
          let(:current_step) { :select_option }
          let(:application_choice) { create(:application_choice) }
          let(:application_choice_id) { application_choice.id }
          let(:course_option_id) { application_choice.current_course_option.id }

          before do
            application_choice.course_option.course.subjects.delete_all
            application_choice.course_option.course.subjects << build(:subject, code: '15', name: 'Portuguese')
          end

          it 'returns :ske_requirements' do
            expect(wizard.next_step).to eq(:ske_requirements)
          end

          context 'when on the ske language flow' do
            let(:current_step) { :ske_requirements }

            context 'when no course required is selected' do
              let(:ske_conditions) { [] }

              it 'returns :conditions' do
                expect(wizard.next_step).to eq(:conditions)
              end
            end

            context 'when languages are selected' do
              let(:subjects) { %w[French Spanish] }

              it 'returns :ske_reason' do
                expect(wizard.next_step).to eq(:ske_reason)
              end
            end
          end
        end
      end
    end

    describe '#available_changes?' do
      let(:provider_user) { instance_double(ProviderUser) }
      let(:provider) { instance_double(Provider) }
      let(:course) { instance_double(Course) }
      let(:query_service) { instance_double(GetChangeOfferOptions) }

      before do
        allow(ProviderUser).to receive(:find).and_return(provider_user)
        allow(GetChangeOfferOptions).to receive(:new).and_return(query_service)

        allow(query_service).to receive_messages(available_courses: create_list(:course, 1), available_study_modes: %w[full_time], available_course_options: create_list(:course_option, 1))
      end

      context 'when there are no available changes for this offer' do
        before do
          allow(Provider).to receive(:find).and_return(provider)
          allow(Course).to receive(:find).and_return(course)

          allow(query_service).to receive(:available_providers).and_return(create_list(:provider, 1))
        end

        it 'returns false' do
          expect(wizard.available_changes?).to be(false)
        end
      end

      context 'when there are available changes for this offer' do
        before do
          allow(query_service).to receive(:available_providers).and_return(create_list(:provider, 2))
        end

        it 'returns true' do
          expect(wizard.available_changes?).to be(true)
        end
      end
    end

    context 'when changing an offer' do
      let(:decision) { :change_offer }
      let(:query_service) { instance_double(GetChangeOfferOptions) }
      let(:provider_user) { instance_double(ProviderUser) }
      let(:provider_id) { create(:provider).id }
      let(:course_id) { create(:course).id }
      let(:course_option_id) { create(:course_option).id }

      before do
        allow(ProviderUser).to receive(:find).and_return(provider_user)
        allow(provider_user).to receive(:id).and_return(1)
        allow(GetChangeOfferOptions).to receive(:new).and_return(query_service)
        allow(store).to receive(:write)
      end

      context 'when current_step is :select_option' do
        let(:current_step) { :select_option }

        context 'when there are multiple available providers' do
          before do
            allow(query_service).to receive(:available_providers).and_return(create_list(:provider, 2))
          end

          it 'returns :providers' do
            expect(wizard.next_step).to eq(:providers)
          end
        end

        context 'when there is only one available provider' do
          before do
            allow(query_service).to receive_messages(available_providers: [create(:provider)], available_courses: create_list(:course, 2))
          end

          it 'returns :courses' do
            expect(wizard.next_step).to eq(:courses)
          end
        end
      end

      context 'when current_step is :providers' do
        let(:current_step) { :providers }

        context 'when there are multiple available courses' do
          before do
            allow(query_service).to receive(:available_courses).and_return(create_list(:course, 2))
          end

          it 'returns :courses' do
            expect(wizard.next_step).to eq(:courses)
          end
        end

        context 'when there is only one available course' do
          before do
            allow(query_service).to receive_messages(available_courses: [create(:course)], available_study_modes: %w[full_time part_time])
          end

          it 'returns :study_modes' do
            expect(wizard.next_step).to eq(:study_modes)
          end
        end
      end

      context 'when current_step is :courses' do
        let(:current_step) { :courses }

        context 'when there are multiple available study modes' do
          before do
            allow(query_service).to receive(:available_study_modes).and_return(%w[full_time part_time])
          end

          it 'returns :study_modes' do
            expect(wizard.next_step).to eq(:study_modes)
          end
        end

        context 'when there is only one study mode' do
          before do
            allow(query_service).to receive_messages(available_study_modes: %w[part_time], available_course_options: create_list(:course_option, 2))
          end

          it 'returns :study_modes' do
            expect(wizard.next_step).to eq(:locations)
          end
        end
      end

      context 'when current_step is :study_modes' do
        let(:current_step) { :study_modes }

        context 'when there are multiple locations available' do
          before do
            allow(query_service).to receive(:available_course_options).and_return(create_list(:course_option, 2))
          end

          it 'returns :locations' do
            expect(wizard.next_step).to eq(:locations)
          end
        end

        context 'when there is only one available location' do
          before do
            allow(query_service).to receive(:available_course_options).and_return([create(:course_option)])
          end

          it 'returns :conditions' do
            expect(wizard.next_step).to eq(:conditions)
          end
        end
      end

      context 'when current_step is :locations' do
        let(:current_step) { :locations }

        context 'when ske is not required' do
          it 'returns :conditions' do
            expect(wizard.next_step).to eq(:conditions)
          end
        end

        context 'when ske is required' do
          before do
            wizard.course_option.course.subjects.delete_all
            wizard.course_option.course.subjects << build(:subject, code: 'F1', name: 'Chemistry')
          end

          it 'returns :ske_requirements' do
            expect(wizard.next_step).to eq(:ske_requirements)
          end
        end
      end

      context 'when current_step is :conditions' do
        let(:current_step) { :conditions }

        it 'returns :conditions' do
          expect(wizard.next_step).to eq(:check)
        end
      end
    end
  end

  describe '#conditions' do
    context 'when adding conditions to an offer' do
      let(:standard_conditions) { ['', OfferCondition::STANDARD_CONDITIONS.last] }
      let(:further_condition_1) { 'Receiving an A* on their Maths A Level' }
      let(:further_condition_3) { 'They must graduate from their current course with an Honors' }

      it 'constructs an array with the offer conditions' do
        expect(wizard.conditions).to eq([OfferCondition::STANDARD_CONDITIONS.last,
                                         further_condition_1,
                                         further_condition_3])
      end
    end

    context 'when adding duplicated conditions to an offer' do
      let(:standard_conditions) { [''] }
      let(:further_condition_1) { 'This is a duplicated condition' }
      let(:further_condition_2) { 'This is a duplicated condition' }

      it 'constructs an array with the offer conditions' do
        expect(wizard.conditions).to eq([further_condition_1,
                                         further_condition_2])
      end
    end
  end

  describe '#max_number_of_further_conditions?' do
    context 'when there are fewer than 18 conditions already set' do
      let(:further_conditions) { Array.new(17, 'be cool') }

      it 'returns false' do
        expect(wizard.max_number_of_further_conditions?).to be(false)
      end
    end

    context 'when there are 18 conditions already set' do
      let(:further_conditions) { Array.new(18, 'be cool') }

      it 'returns true' do
        expect(wizard.max_number_of_further_conditions?).to be(true)
      end
    end

    context 'when there are more than 18 conditions already set' do
      let(:further_conditions) { Array.new(19, 'be cool') }

      it 'returns true' do
        expect(wizard.max_number_of_further_conditions?).to be(true)
      end
    end
  end

  describe '#add_empty_condition' do
    let(:further_condition_1) { 'Be cool' }
    let(:further_condition_2) { 'Degree certificate' }

    before do
      allow(store).to receive(:write)
    end

    def further_conditions_array
      wizard.further_condition_attrs.values.map { |hash| hash['text'] }
    end

    it 'appends a blank condition to the array of further conditions' do
      expect { wizard.add_empty_condition }.to change { further_conditions_array.length }.from(2).to(3)

      expect(further_conditions_array.last).to eq('')
    end

    context 'when there are 18 conditions already set' do
      let(:further_conditions) { Array.new(18, 'be cool') }

      it 'does not append a blank condition to the array of further conditions' do
        expect { wizard.add_empty_condition }.not_to(change { further_conditions_array })

        expect(further_conditions_array.last).to eq('be cool')
      end
    end
  end

  describe '#remove_condition' do
    let(:further_condition_1) { 'Be cool' }
    let(:further_condition_2) { 'Degree certificate' }

    before do
      allow(store).to receive(:write)
    end

    it 'removes the further condition at the specified index' do
      expect { wizard.remove_condition('0') }.to change { wizard.further_condition_attrs.length }.from(2).to(1)

      expect(wizard.further_condition_attrs).to eq({ '0' => { 'text' => 'Degree certificate' } })
    end

    context 'when there are no conditions already set' do
      let(:further_conditions) { [] }

      it 'does nothing' do
        expect { wizard.remove_condition('0') }.not_to(change { wizard.further_condition_attrs })
      end
    end
  end

  describe '#remove_empty_conditions!' do
    let(:further_conditions) { ['', 'Be cool', ''] }

    before do
      allow(store).to receive(:write)
    end

    it 'removes any blank further conditions' do
      expect { wizard.remove_empty_conditions! }.to change { wizard.further_condition_attrs.length }.from(3).to(1)

      expect(wizard.further_condition_attrs).to eq({ '0' => { 'text' => 'Be cool' } })
    end
  end

  describe '#require_references' do
    context 'when require references is checked' do
      it 'returns checked' do
        wizard.require_references = '1'
        expect(wizard.require_references).to be(1)
      end
    end

    context 'when require references is unchecked' do
      it 'returns unchecked' do
        wizard.require_references = '0'
        expect(wizard.require_references).to be_zero
      end
    end
  end

  describe '#references_description' do
    context 'when reference is required' do
      before do
        wizard.require_references = '1'
        wizard.references_description = 'Something'
      end

      it 'returns nil' do
        expect(wizard.references_description).to eq('Something')
      end
    end

    context 'when reference is not required' do
      before do
        wizard.require_references = '0'
        wizard.references_description = 'Something'
      end

      it 'returns nil' do
        expect(wizard.references_description).to be_nil
      end
    end
  end

  describe '#conditions_to_render' do
    context 'when there are no conditions' do
      it 'does not display a condition' do
        expect(wizard.conditions_to_render.size).to be_zero
      end
    end

    context 'when there are conditions' do
      let(:further_condition_1) { Faker::Lorem.paragraph_by_chars(number: 300) }
      let(:further_condition_2) { Faker::Lorem.paragraph_by_chars(number: 300) }

      it 'does display conditions' do
        expect(wizard.conditions_to_render.size).to be(2)
      end

      context 'when a reference condition is present' do
        let(:require_references) { '1' }
        let(:references_description) { Faker::Lorem.paragraph_by_chars(number: 300) }

        context 'when the reference attribute if true' do
          it 'displays the reference condition' do
            rendered_condition = wizard.conditions_to_render
            expect(rendered_condition.size).to be(3)
            expect(
              rendered_condition
                .map { |condition| condition.details[:description] },
            ).to include(references_description)
          end
        end

        context 'when the references attribute if false' do
          it 'does not display the reference condition' do
            rendered_condition = wizard.conditions_to_render(references: false)
            expect(rendered_condition.size).to be(2)
            expect(
              rendered_condition
                .map { |condition| condition.details[:description] },
            ).not_to include(references_description)
          end
        end
      end
    end
  end

  describe '#structured_conditions' do
    let(:subjects) { %w[French Spanish] }

    context 'when no reference condition' do
      it 'returns ske conditions' do
        expect(wizard.structured_conditions.size).to be(2)
        expect(wizard.structured_conditions).to all be_a(SkeCondition)
      end
    end

    context 'when new reference condition' do
      before do
        wizard.require_references = 1
      end

      it 'returns ske conditions and reference condition' do
        expect(wizard.structured_conditions.size).to be(3)
      end

      it 'returns all structured conditions' do
        expect(wizard.structured_conditions.last).to be_a(ReferenceCondition)
      end
    end
  end
end
