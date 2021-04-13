require 'rails_helper'

RSpec.describe ProviderInterface::ReasonsForRejectionWizard do
  let(:store) { instance_double(WizardStateStores::RedisStore) }

  before { allow(store).to receive(:read) }

  describe '#valid_for_current_step?' do
    let(:current_step) { 'initial_questions' }
    let(:wizard_params) { { current_step: current_step } }

    subject(:wizard) { described_class.new(store, wizard_params) }

    it 'validates top level questions' do
      wizard.valid_for_current_step?

      expect(wizard.errors.attribute_names.sort).to eq(
        %i[
          candidate_behaviour_y_n
          course_full_y_n
          honesty_and_professionalism_y_n
          offered_on_another_course_y_n
          performance_at_interview_y_n
          qualifications_y_n
          quality_of_application_y_n
          safeguarding_y_n
        ],
      )
    end

    context 'when top level question is answered' do
      let(:wizard_params) do
        {
          current_step: 'initial_questions',
          candidate_behaviour_y_n: 'Yes',
          course_full_y_n: 'Yes',
          honesty_and_professionalism_y_n: 'Yes',
          offered_on_another_course_y_n: 'Yes',
          performance_at_interview_y_n: 'Yes',
          qualifications_y_n: 'Yes',
          quality_of_application_y_n: 'Yes',
          safeguarding_y_n: 'Yes',
        }
      end

      it 'validates second level options' do
        wizard.valid_for_current_step?

        expect(wizard.errors.attribute_names.sort).to eq(
          %i[
            candidate_behaviour_what_did_the_candidate_do
            honesty_and_professionalism_concerns
            offered_on_another_course_details
            performance_at_interview_what_to_improve
            qualifications_which_qualifications
            quality_of_application_which_parts_needed_improvement
            safeguarding_concerns
          ],
        )
      end
    end

    context 'when top and second level questions are answered' do
      let(:wizard_params) do
        {
          current_step: 'initial_questions',
          candidate_behaviour_y_n: 'Yes',
          candidate_behaviour_what_did_the_candidate_do: %w[other],
          course_full_y_n: 'Yes',
          honesty_and_professionalism_y_n: 'Yes',
          honesty_and_professionalism_concerns: %w[information_false_or_inaccurate plagiarism references other],
          offered_on_another_course_y_n: 'Yes',
          performance_at_interview_y_n: 'Yes',
          qualifications_y_n: 'Yes',
          qualifications_which_qualifications: %w[other],
          quality_of_application_y_n: 'Yes',
          quality_of_application_which_parts_needed_improvement: %w[other],
          safeguarding_y_n: 'Yes',
          safeguarding_concerns: %w[candidate_disclosed_information vetting_disclosed_information other],
        }
      end

      let(:long_text) { Faker::Lorem.sentence(word_count: 101) }

      it 'validates details and advice fields' do
        wizard.valid_for_current_step?

        expect(wizard.errors.attribute_names.sort).to eq(
          %i[
            candidate_behaviour_other
            candidate_behaviour_what_to_improve
            honesty_and_professionalism_concerns_information_false_or_inaccurate_details
            honesty_and_professionalism_concerns_other_details
            honesty_and_professionalism_concerns_plagiarism_details
            honesty_and_professionalism_concerns_references_details
            offered_on_another_course_details
            performance_at_interview_what_to_improve
            qualifications_other_details
            quality_of_application_other_details
            quality_of_application_other_what_to_improve
            safeguarding_concerns_candidate_disclosed_information_details
            safeguarding_concerns_other_details
            safeguarding_concerns_vetting_disclosed_information_details
          ],
        )
      end

      it 'validates length of text in details and advice fields' do
        wizard_params[:candidate_behaviour_other] = long_text
        wizard_params[:candidate_behaviour_what_to_improve] = long_text
        wizard_params[:honesty_and_professionalism_concerns_information_false_or_inaccurate_details] = long_text
        wizard_params[:honesty_and_professionalism_concerns_plagiarism_details] = long_text
        wizard_params[:honesty_and_professionalism_concerns_references_details] = long_text
        wizard_params[:honesty_and_professionalism_concerns_other_details] = long_text
        wizard_params[:offered_on_another_course_details] = long_text
        wizard_params[:performance_at_interview_what_to_improve] = long_text
        wizard_params[:qualifications_other_details] = long_text
        wizard_params[:quality_of_application_other_details] = long_text
        wizard_params[:quality_of_application_other_what_to_improve] = long_text
        wizard_params[:safeguarding_concerns_candidate_disclosed_information_details] = long_text
        wizard_params[:safeguarding_concerns_vetting_disclosed_information_details] = long_text
        wizard_params[:safeguarding_concerns_other_details] = long_text

        wizard.valid_for_current_step?

        expect(wizard.errors.attribute_names.sort).to eq(
          %i[
            candidate_behaviour_other
            candidate_behaviour_what_to_improve
            honesty_and_professionalism_concerns_information_false_or_inaccurate_details
            honesty_and_professionalism_concerns_other_details
            honesty_and_professionalism_concerns_plagiarism_details
            honesty_and_professionalism_concerns_references_details
            offered_on_another_course_details
            performance_at_interview_what_to_improve
            qualifications_other_details
            quality_of_application_other_details
            quality_of_application_other_what_to_improve
            safeguarding_concerns_candidate_disclosed_information_details
            safeguarding_concerns_other_details
            safeguarding_concerns_vetting_disclosed_information_details
          ],
        )

        expect(wizard.errors.details.values.flatten.map { |v| v[:error] }.uniq).to eq(%i[too_long])
      end
    end

    context "when top level question is answered 'No'" do
      let(:wizard_params) do
        {
          current_step: 'initial_questions',
          candidate_behaviour_y_n: 'No',
          course_full_y_n: 'No',
          honesty_and_professionalism_y_n: 'No',
          offered_on_another_course_y_n: 'No',
          performance_at_interview_y_n: 'No',
          qualifications_y_n: 'No',
          quality_of_application_y_n: 'No',
          safeguarding_y_n: 'No',
        }
      end

      it 'skips validation on other fields' do
        wizard.valid_for_current_step?

        expect(wizard.errors.attribute_names.sort).to be_empty
      end
    end

    context "when top level question is answered 'Yes' and some other reasons are selected" do
      let(:wizard_params) do
        {
          current_step: 'initial_questions',
          candidate_behaviour_y_n: 'No',
          course_full_y_n: 'No',
          honesty_and_professionalism_y_n: 'Yes',
          honesty_and_professionalism_concerns: %w[information_false_or_inaccurate],
          offered_on_another_course_y_n: 'No',
          performance_at_interview_y_n: 'No',
          qualifications_y_n: 'No',
          quality_of_application_y_n: 'No',
          safeguarding_y_n: 'No',
        }
      end

      it 'validates the selected reasons' do
        wizard.valid_for_current_step?

        expect(wizard.errors.attribute_names).to eq(%i[honesty_and_professionalism_concerns_information_false_or_inaccurate_details])
      end
    end

    context 'other_reasons step' do
      let(:current_step) { 'other_reasons' }

      it 'validates top level questions' do
        wizard.valid_for_current_step?

        expect(wizard.errors.attribute_names.sort).to eq(%i[other_advice_or_feedback_y_n])
      end
    end

    context 'other_reasons step when top level answers are Yes' do
      let(:wizard_params) do
        {
          current_step: 'other_reasons',
          other_advice_or_feedback_y_n: 'Yes',
        }
      end

      it 'validates second level reasons fields' do
        wizard.valid_for_current_step?

        expect(wizard.errors.attribute_names).to eq(%i[other_advice_or_feedback_details])
      end
    end
  end

  describe '#needs_other_reasons?' do
    it 'is true when honesty & professionalism and safeguarding answers are No' do
      expect(
        described_class.new(
          store,
          current_step: 'initial_questions',
          honesty_and_professionalism_y_n: 'No',
          safeguarding_y_n: 'No',
        ).needs_other_reasons?,
      ).to be true
    end

    it 'is false when either honesty & professionalism and safeguarding answers are Yes' do
      expect(
        described_class.new(
          store,
          current_step: 'initial_questions',
          honesty_and_professionalism_y_n: 'Yes',
          safeguarding_y_n: 'No',
        ).needs_other_reasons?,
      ).to be false
    end
  end

  describe '#next_step' do
    it 'is other_reasons when the current step is initial_questions, needs_other_reasons is true' do
      expect(
        described_class.new(
          store,
          current_step: 'initial_questions',
          honesty_and_professionalism_y_n: 'No',
          safeguarding_y_n: 'No',
        ).next_step,
      ).to eq 'other_reasons'
    end

    it 'is check when the current step is initial_questions and needs_other_reasons is false' do
      expect(
        described_class.new(
          store,
          current_step: 'initial_questions',
          honesty_and_professionalism_y_n: 'No',
          safeguarding_y_n: 'Yes',
        ).next_step,
      ).to eq 'check'
    end

    it 'is check when the current step is other_reasons' do
      expect(
        described_class.new(
          store,
          current_step: 'other_reasons',
        ).next_step,
      ).to eq 'check'
    end
  end

  describe 'nested answers' do
    let(:attrs_with_nested_answers) do
      {
        current_step: 'initial_questions',
        candidate_behaviour_y_n: 'No',
        candidate_behaviour_what_did_the_candidate_do: %w[other],
        candidate_behaviour_other: 'Blah',
        candidate_behaviour_what_to_improve: 'Less blah',
        quality_of_application_y_n: 'No',
        quality_of_application_which_parts_needed_improvement: %w[personal_statement subject_knowledge other],
        quality_of_application_personal_statement_what_to_improve: 'AAA',
        quality_of_application_subject_knowledge_what_to_improve: 'BBB',
        quality_of_application_other_details: 'CCC',
        quality_of_application_other_what_to_improve: 'DDD',
        qualifications_y_n: 'No',
        qualifications_which_qualifications: %w[other],
        qualifications_other_details: 'Nyyyyyyaaah',
        performance_at_interview_y_n: 'No',
        performance_at_interview_what_to_improve: 'Be better',
        offered_on_another_course_y_n: 'No',
        offered_on_another_course_details: 'ZZZ',
        honesty_and_professionalism_y_n: 'No',
        honesty_and_professionalism_concerns: %w[information_false_or_inaccurate plagiarism references other],
        honesty_and_professionalism_concerns_information_false_or_inaccurate_details: 'AAA',
        honesty_and_professionalism_concerns_plagiarism_details: 'BBB',
        honesty_and_professionalism_concerns_references_details: 'CCC',
        honesty_and_professionalism_concerns_other_details: 'DDD',
        safeguarding_y_n: 'No',
        safeguarding_concerns: %w[candidate_disclosed_information vetting_disclosed_information other],
        safeguarding_concerns_candidate_disclosed_information_details: 'PPP',
        safeguarding_concerns_vetting_disclosed_information_details: 'QQQ',
        safeguarding_concerns_other_details: 'GGG',
      }
    end

    subject(:wizard) { described_class.new(store, attrs_with_nested_answers) }

    it 'ignores existing nested answers when top level answer is No' do
      expect(wizard.candidate_behaviour_what_did_the_candidate_do).to eq([])
      expect(wizard.candidate_behaviour_other).to be nil
      expect(wizard.candidate_behaviour_what_to_improve).to be nil

      expect(wizard.quality_of_application_which_parts_needed_improvement).to eq([])
      expect(wizard.quality_of_application_personal_statement_what_to_improve).to be nil
      expect(wizard.quality_of_application_subject_knowledge_what_to_improve).to be nil
      expect(wizard.quality_of_application_other_details).to be nil
      expect(wizard.quality_of_application_other_what_to_improve).to be nil

      expect(wizard.qualifications_which_qualifications).to eq([])
      expect(wizard.qualifications_other_details).to be nil

      expect(wizard.performance_at_interview_what_to_improve).to be nil
      expect(wizard.offered_on_another_course_details).to be nil

      expect(wizard.honesty_and_professionalism_concerns).to eq([])
      expect(wizard.honesty_and_professionalism_concerns_information_false_or_inaccurate_details).to be nil
      expect(wizard.honesty_and_professionalism_concerns_plagiarism_details).to be nil
      expect(wizard.honesty_and_professionalism_concerns_references_details).to be nil
      expect(wizard.honesty_and_professionalism_concerns_other_details).to be nil

      expect(wizard.safeguarding_concerns).to eq([])
      expect(wizard.safeguarding_concerns_candidate_disclosed_information_details).to be nil
      expect(wizard.safeguarding_concerns_vetting_disclosed_information_details).to be nil
      expect(wizard.safeguarding_concerns_other_details).to be nil
    end

    # eg.
    # candidate_behaviour_y_n: 'Yes'
    # candidate_behaviour_what_did_the_candidate_do: [didnt_attend_interview]
    # candidate_behaviour_other: 'Some text' <- this value should be cleared
    it 'ignores nested answers when parent is not selected' do
      ReasonsForRejection::INITIAL_TOP_LEVEL_QUESTIONS.each { |q| attrs_with_nested_answers[q] = 'Yes' }

      attrs_with_nested_answers[:candidate_behaviour_what_did_the_candidate_do] = %w[didnt_attend_interview]
      attrs_with_nested_answers[:quality_of_application_which_parts_needed_improvement] = %w[personal_statement]
      attrs_with_nested_answers[:qualifications_which_qualifications] = %w[no_degree]
      attrs_with_nested_answers[:honesty_and_professionalism_concerns] = %w[information_false_or_inaccurate]
      attrs_with_nested_answers[:safeguarding_concerns] = %w[other]

      expect(wizard.candidate_behaviour_other).to be nil
      expect(wizard.candidate_behaviour_what_to_improve).to be nil

      expect(wizard.quality_of_application_personal_statement_what_to_improve).to eq(
        attrs_with_nested_answers[:quality_of_application_personal_statement_what_to_improve],
      )
      expect(wizard.quality_of_application_subject_knowledge_what_to_improve).to be nil
      expect(wizard.quality_of_application_other_details).to be nil
      expect(wizard.quality_of_application_other_what_to_improve).to be nil

      expect(wizard.qualifications_other_details).to be nil

      expect(wizard.honesty_and_professionalism_concerns_information_false_or_inaccurate_details).to eq(
        attrs_with_nested_answers[:honesty_and_professionalism_concerns_information_false_or_inaccurate_details],
      )
      expect(wizard.honesty_and_professionalism_concerns_plagiarism_details).to be nil
      expect(wizard.honesty_and_professionalism_concerns_references_details).to be nil
      expect(wizard.honesty_and_professionalism_concerns_other_details).to be nil

      expect(wizard.safeguarding_concerns_candidate_disclosed_information_details).to be nil
      expect(wizard.safeguarding_concerns_vetting_disclosed_information_details).to be nil
      expect(wizard.safeguarding_concerns_other_details).to eq(attrs_with_nested_answers[:safeguarding_concerns_other_details])
    end
  end

  describe 'why_are_you_rejecting_this_application' do
    let(:last_state) do
      {
        candidate_behaviour_y_n: 'No',
        quality_of_application_y_n: 'No',
        qualifications_y_n: 'No',
        performance_at_interview_y_n: 'No',
        course_full_y_n: 'No',
        offered_on_another_course_y_n: 'No',
        honesty_and_professionalism_y_n: 'No',
        safeguarding_y_n: 'No',
      }
    end

    subject(:wizard) { described_class.new(store, current_step: 'other_reasons', why_are_you_rejecting_this_application: 'I am drunk with power') }

    it 'value is set if all top level initial questions were answered No' do
      allow(store).to receive(:read).and_return(last_state.to_json)

      expect(wizard.why_are_you_rejecting_this_application).to eq('I am drunk with power')
    end

    it 'value is ignored unless all top level initial questions were answered No' do
      last_state[:course_full_y_n] = 'Yes'
      allow(store).to receive(:read).and_return(last_state.to_json)

      expect(wizard.why_are_you_rejecting_this_application).to be nil
    end
  end

  describe 'other reasons when checking answers' do
    let(:last_state) do
      {
        why_are_you_rejecting_this_application: 'reasons',
        other_advice_or_feedback_y_n: 'Yes',
        other_advice_or_feedback_details: 'details',
        interested_in_future_applications_y_n: 'Yes',
        honesty_and_professionalism_y_n: 'Yes',
        safeguarding_y_n: 'No',
      }
    end

    subject(:wizard) do
      described_class.new(
        store,
        current_step: 'check',
      )
    end

    it 'are reset to nil unless they are necessary' do
      allow(store).to receive(:read).and_return(last_state.to_json)

      expect(wizard.why_are_you_rejecting_this_application).to be nil
      expect(wizard.other_advice_or_feedback_y_n).to be nil
      expect(wizard.other_advice_or_feedback_details).to be nil
    end
  end
end
