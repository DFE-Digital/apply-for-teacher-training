require 'rails_helper'

RSpec.describe RejectionReasons::RejectionReasonsPresenter do
  describe '#rejection_reasons' do
    let(:reasons) { {} }
    let(:application_choice) do
      build_stubbed(
        :application_choice,
        structured_rejection_reasons: reasons,
        rejection_reasons_type: 'rejection_reasons',
      )
    end

    let(:rejected_application_choice) { described_class.new(application_choice) }

    describe 'when there are no rejection reasons' do
      it 'returns an empty hash' do
        expect(rejected_application_choice.rejection_reasons).to eq({})
      end
    end

    describe 'reasons with nested reasons' do
      let(:reasons) do
        {
          selected_reasons: [
            { id: 'qualifications', label: 'Qualifications', selected_reasons: [
              { id: 'no_maths_gcse', label: 'No maths GCSE at minimum grade 4 or C, or equivalent' },
              other_reason,
            ] },
          ],
        }
      end

      let(:other_reason) do
        { id: 'qualifications_other', label: 'Other', details: { id: 'qualifications_other_details', text: 'Some other text' } }
      end

      it 'adds nested reasons as values keyed by top level reason label' do
        expect(rejected_application_choice.rejection_reasons).to eq({
          'Qualifications' => [
            'No maths GCSE at minimum grade 4 or C, or equivalent.',
            'Other:',
            'Some other text',
          ],
        })
      end

      it "conditionally omits the 'Other:' label when only this reason is selected." do
        reasons[:selected_reasons].first[:selected_reasons] = [other_reason]

        expect(rejected_application_choice.rejection_reasons).to eq({
          'Qualifications' => ['Some other text'],
        })
      end
    end

    describe 'reasons with details' do
      let(:reasons) do
        {
          selected_reasons: [
            { id: 'other', label: 'Other', details: { id: 'other_details', text: 'Some text?' } },
          ],
        }
      end

      it 'returns the details text keyed with the top level reason label' do
        expect(rejected_application_choice.rejection_reasons).to eq({ 'Other' => ['Some text?'] })
      end
    end

    describe 'reasons with optional details and no nested reasons' do
      let(:reasons) do
        { selected_reasons: [{ id: 'course_full', label: 'Course full', details: }] }
      end

      let(:details) { { id: 'course_full_details', text:, optional: true } }
      let(:text) { '' }

      it 'returns i18n translation keyed with the top level reason label when text is blank' do
        expect(rejected_application_choice.rejection_reasons).to eq({ 'Course full' => ['The course is full.'] })
      end

      context 'when optional details text is present' do
        let(:text) { 'Try another course, we provide many!' }

        it 'returns details text with the top level reason label when text is present' do
          expect(rejected_application_choice.rejection_reasons).to eq({ 'Course full' => ['Try another course, we provide many!'] })
        end
      end
    end
  end

  describe '#tailored_advice_reasons' do
    let(:reasons) { {} }
    let(:application_choice) do
      build_stubbed(
        :application_choice,
        structured_rejection_reasons: reasons,
        rejection_reasons_type: 'rejection_reasons',
      )
    end

    let(:rejected_application_choice) { described_class.new(application_choice) }

    describe 'when there are no rejection reasons' do
      it 'returns an empty hash' do
        expect(rejected_application_choice.tailored_advice_reasons).to eq({})
      end
    end

    describe 'when placement related reasons are selected' do
      let(:reasons) do
        {
          selected_reasons: [
            {
              id: 'school_placement',
              label: 'School placement',
              selected_reasons: [
                {
                  id: 'no_placements',
                  label: 'No available placements',
                  details: { id: 'no_placements_details', text: 'No placements reason' },
                }, {
                  id: 'no_suitable_placements',
                  label: 'No placements that are suitable',
                  details: { id: 'no_suitable_placements_details', text: 'No suitable placements' },
                }, {
                  id: 'placements_other',
                  label: 'Other',
                  details: { id: 'placements_other_details', text: 'Other placements reason' },
                }
              ],
            },
          ],
        }
      end

      it 'returns no_suitable_placements only' do
        expect(rejected_application_choice.tailored_advice_reasons).to match({ 'school_placement' => ['placements_other'] })
      end
    end

    describe 'with multiple gcse rejection reasons' do
      let(:reasons) do
        { selected_reasons: [
          { id: 'qualifications', label: 'Qualifications',
            selected_reasons: [{ id: 'no_maths_gcse', label: 'No maths GCSE at minimum grade 4 or C, or equivalent' },
                               { id: 'no_english_gcse', label: 'No english GCSE at minimum grade 4 or C, or equivalent' },
                               { id: 'no_science_gcse', label: 'No english GCSE at minimum grade 4 or C, or equivalent' },
                               { id: 'already_qualified', label: 'Already has a teaching qualification' }] },
        ] }
      end

      it 'only returns a single "no_gcse" reason code for all gcses,' do
        expect(rejected_application_choice.tailored_advice_reasons).to eq({ 'qualifications' => %w[no_gcse already_qualified] })
      end
    end

    describe 'when both personal statement options are chosen' do
      let(:reasons) do
        { selected_reasons: [
          { id: 'personal_statement', label: 'Personal statement',
            selected_reasons: [{ id: 'quality_of_writing', label: 'Quality of writing' },
                               { id: 'personal_statement_other', label: 'Other' }] },
        ] }
      end

      it 'only returns a single personal statement option' do
        expect(rejected_application_choice.tailored_advice_reasons).to eq({ 'personal_statement' => ['personal_statement_other'] })
      end
    end

    describe 'when communication_and_scheduling options include both couldn_not_arrange_interview and communication_and_scheduling_other' do
      let(:reasons) do
        { selected_reasons: [
          { id: 'communication_and_scheduling', label: 'Communication, interview attendance and scheduling', selected_reasons: [
            { id: 'could_not_arrange_interview', label: 'Could not arrange interview' },
            { id: 'communication_and_scheduling_other', label: 'Other' },
          ] },
        ] }
      end

      it 'consolidates the reasons to just communication_and_scheduling_other' do
        expect(rejected_application_choice.tailored_advice_reasons).to eq(
          { 'communication_and_scheduling' => %w[communication_and_scheduling_other] },
        )
      end
    end

    describe 'when communication_and_scheduling_includes english_below_standard' do
      let(:reasons) do
        { selected_reasons: [
          { id: 'communication_and_scheduling', label: 'Communication, interview attendance and scheduling', selected_reasons: [
            { id: 'could_not_arrange_interview', label: 'Could not arrange interview' },
            { id: 'communication_and_scheduling_other', label: 'Other' },
            { id: 'english_below_standard',
              label: 'English language ability below expected standard',
              details: { id: 'english_below_standard_details', text: 'details about English language ability' } },
          ] },
        ] }
      end

      it 'includes english_below_standard in nested reasons' do
        expect(rejected_application_choice.tailored_advice_reasons['communication_and_scheduling']).to match_array(
          %w[communication_and_scheduling_other english_below_standard],
        )
      end
    end

    describe 'when the teaching knowledge selected reasons include classroom experience related reason codes' do
      let(:reasons) do
        { selected_reasons: [
          { id: 'teaching_knowledge', label: 'Teaching knowledge, ability and interview performance',
            selected_reasons: [{ id: 'subject_knowledge', label: 'Subject knowledge' },
                               { id: 'safeguarding_knowledge', label: 'Safeguarding knowledge' },
                               { id: 'teaching_method_knowledge', label: 'Teaching method knowledge' },
                               { id: 'teaching_role_knowledge', label: 'Teaching role knowledge' },
                               { id: 'teaching_knowledge_other', label: 'Other' },
                               { id: 'teaching_demonstration', label: 'Teaching demonstration' }] },
        ] }
      end

      it 'consolidates the classroom experience related reasons' do
        expect(rejected_application_choice.tailored_advice_reasons).to eq(
          { 'teaching_knowledge' => %w[subject_knowledge teaching_knowledge_other] },
        )
      end
    end

    describe 'when multiple communication other reason codes are given' do
      let(:reasons) do
        { selected_reasons: [
          { id: 'communication_and_scheduling', label: 'Communication, interview attendance and scheduling',
            selected_reasons: [
              { id: 'could_not_arrange_interview', label: 'Could not arrange interview' },
              { id: 'did_not_reply', label: 'Did not reply to messages' },
              { id: 'communication_and_scheduling_other', label: 'Other' },
            ] },
        ] }
      end

      it 'returns only communication_and_schedule_other' do
        expect(rejected_application_choice.tailored_advice_reasons).to eq(
          { 'communication_and_scheduling' => ['communication_and_scheduling_other'] },
        )
      end
    end

    describe 'when a deprecated or invalid high level advice reason code is given' do
      let(:reasons) do
        { selected_reasons: [
          {
            id: 'qualifications',
            label: 'Qualifications',
            details: {
              id: 'qualifications_details', text: 'We could find no record of your GCSEs.'
            },
          },
          {
            id: 'personal_statement',
            label: 'Personal statement',
            details: {
              id: 'personal_statement_details', text: 'We do not accept applications written in Old Norse.'
            },
          },
          {
            id: 'references',
            label: 'References',
            details: {
              id: 'references_details',
              text: 'We do not accept references from close family members, such as your mum.',
            },
          },
          {
            id: 'some_random_thing',
            label: 'Some Random Thing',
          },
        ] }
      end

      it 'does not return the deprecated reasons' do
        expect(rejected_application_choice.tailored_advice_reasons.keys).to contain_exactly('qualifications', 'personal_statement')
      end
    end

    describe 'does not return both safeguarding and other high-level reasons' do
      context 'only other is a reason' do
        let(:reasons) do
          { selected_reasons: [
            { id: 'other', label: 'Other', details: { id: 'other_details', text: 'Other things.' } },
          ] }
        end

        it 'returns other' do
          expect(rejected_application_choice.tailored_advice_reasons.keys).to contain_exactly('other')
        end
      end

      context 'when there is no need of tailored advice' do
        let(:application_choice) do
          build_stubbed(
            :application_choice,
            :insufficient_a_levels_rejection_reasons,
          )
        end

        it 'ignores tailored advice' do
          expect(rejected_application_choice.tailored_advice_reasons).to eq('qualifications' => [])
        end
      end

      context 'only safeguarding is a reason' do
        let(:reasons) do
          { selected_reasons: [
            { id: 'safeguarding', label: 'Safeguarding', details: { id: 'safeguarding_details', text: 'Safeguarding.' } },
          ] }
        end

        it 'returns other' do
          expect(rejected_application_choice.tailored_advice_reasons.keys).to contain_exactly('safeguarding')
        end
      end

      context 'both other and safeguarding are reasons' do
        let(:reasons) do
          { selected_reasons: [
            { id: 'safeguarding', label: 'Safeguarding', details: { id: 'safeguarding_details', text: 'Safeguarding.' } },
            { id: 'other', label: 'Other', details: { id: 'other_details', text: 'Other things.' } },
          ] }
        end

        it 'returns other' do
          expect(rejected_application_choice.tailored_advice_reasons.keys).to contain_exactly('other')
        end
      end
    end
  end

  describe '#render_tailored_advice_section_headings?' do
    let(:reasons) { {} }
    let(:application_choice) do
      build_stubbed(
        :application_choice,
        structured_rejection_reasons: reasons,
        rejection_reasons_type: 'rejection_reasons',
      )
    end

    let(:rejected_application_choice) { described_class.new(application_choice) }

    describe 'when there are multiple high level reasons' do
      let(:reasons) do
        { selected_reasons: [
          { id: 'teaching_knowledge', label: 'Teaching knowledge, ability and interview performance',
            selected_reasons: [{ id: 'teaching_demonstration', label: 'Teaching demonstration' }] },
          { id: 'personal_statement', label: 'Personal statement',
            selected_reasons: [{ id: 'personal_statement_other', label: 'Other' }] },
        ] }
      end

      it 'returns true' do
        expect(rejected_application_choice.render_tailored_advice_section_headings?).to be(true)
      end
    end

    describe 'when there is one high level reason with multiple reason codes' do
      let(:reasons) do
        { selected_reasons: [
          { id: 'teaching_knowledge', label: 'Teaching knowledge, ability and interview performance',
            selected_reasons: [{ id: 'subject_knowledge', label: 'Subject knowledge' },
                               { id: 'safeguarding_knowledge', label: 'Safeguarding knowledge' },
                               { id: 'teaching_method_knowledge', label: 'Teaching method knowledge' },
                               { id: 'teaching_role_knowledge', label: 'Teaching role knowledge' },
                               { id: 'teaching_knowledge_other', label: 'Other' },
                               { id: 'teaching_demonstration', label: 'Teaching demonstration' }] },
        ] }
      end

      it 'returns true' do
        expect(rejected_application_choice.render_tailored_advice_section_headings?).to be(true)
      end
    end

    describe 'when there are no details and no nested reasons' do
      let(:reasons) do
        { selected_reasons: [{ id: 'course_full', label: 'course_full' }] }
      end

      it 'returns false' do
        expect(rejected_application_choice.render_tailored_advice_section_headings?).to be(false)
      end
    end
  end
end
