require 'rails_helper'

RSpec.describe CandidateInterface::RejectionReasonsHistory do
  describe '.all_previous_applications' do
    context 'when given an unsupported section for legacy rejection reasons' do
      it 'raises an error' do
        application_form = build(:application_form)

        expect {
          described_class.all_previous_applications(application_form, :juggling_skills)
        }.to raise_error(described_class::UnsupportedSectionError)
      end
    end

    context 'when no previous application' do
      it 'returns an empty array' do
        application_form = create(:application_form)
        expect(
          described_class.all_previous_applications(application_form, :becoming_a_teacher),
        ).to eq []
      end
    end

    it 'returns a history of rejection reasons from previous applications' do
      previous_application_form1 = create(:application_form)
      choice1 = create(:application_choice, :with_old_structured_rejection_reasons, application_form: previous_application_form1)
      choice2 = create(:application_choice, :with_old_structured_rejection_reasons, application_form: previous_application_form1)
      previous_application_form2 = duplicate_application!(previous_application_form1)
      choice3 = create(:application_choice, :with_old_structured_rejection_reasons, application_form: previous_application_form2)
      %w[Bad Good Amazing].zip([choice1, choice2, choice3]).each do |feedback, choice|
        choice.update!(structured_rejection_reasons: choice.structured_rejection_reasons.merge(quality_of_application_personal_statement_what_to_improve: feedback))
      end
      current_application_form = duplicate_application!(previous_application_form2)

      history_items = described_class.all_previous_applications(current_application_form, :becoming_a_teacher)

      expect(history_items).to contain_exactly(
        described_class::HistoryItem.new(choice3.provider.name, :becoming_a_teacher, 'Amazing', 'reasons_for_rejection'),
        described_class::HistoryItem.new(choice2.provider.name, :becoming_a_teacher, 'Good', 'reasons_for_rejection'),
        described_class::HistoryItem.new(choice1.provider.name, :becoming_a_teacher, 'Bad', 'reasons_for_rejection'),
      )
    end

    context 'for current rejection reasons' do
      let(:previous_application_form) { create(:application_form) }
      let!(:application_choice1) { create(:application_choice, :with_structured_rejection_reasons, application_form: previous_application_form, structured_rejection_reasons: rejection_reasons) }
      let(:current_application_form) { duplicate_application!(previous_application_form) }
      let!(:application_choice2) { create(:application_choice, :with_structured_rejection_reasons, application_form: current_application_form) }

      context 'when no reasons for section selected' do
        let(:rejection_reasons) { { selected_reasons: [{ id: 'course_full', label: 'Course full' }] } }

        it 'returns nothing' do
          history_items = described_class.all_previous_applications(current_application_form, :becoming_a_teacher)

          expect(history_items).to be_empty
        end
      end

      context 'when reasons selected for the `becoming_a_teacher` section' do
        let(:rejection_reasons) do
          {
            selected_reasons: [
              {
                id: 'personal_statement',
                label: 'Personal statement',
                selected_reasons: [
                  {
                    id: 'quality_of_writing',
                    label: 'Quality of writing',
                    details: {
                      id: 'quality_of_writing_details',
                      text: 'Quality Bad',
                    },
                  },
                  {
                    id: 'personal_statement_other',
                    label: 'Other',
                    details: {
                      id: 'personal_statement_other_details',
                      text: 'Personal statement Bad',
                    },
                  },
                ],
              },
            ],
          }
        end

        it 'returns the related rejections in history items' do
          history_items = described_class.all_previous_applications(current_application_form, :becoming_a_teacher)

          history_item = history_items.first
          expect(history_items.count).to eq(1)
          expect(history_item.provider_name).to eq(application_choice1.provider.name)
          expect(history_item.section).to eq(:becoming_a_teacher)
          expect(history_item.feedback.flat_map(&:details).map(&:text)).to contain_exactly('Quality Bad', 'Personal statement Bad')
          expect(history_item.feedback_type).to eq('rejection_reasons')
        end
      end

      context 'when reasons selected for the `subject_knowledge` section' do
        let(:rejection_reasons) do
          {
            selected_reasons: [
              {
                id: 'teaching_knowledge',
                label: 'Teaching knowledge, ability and interview performance',
                selected_reasons: [
                  {
                    id: 'subject_knowledge',
                    label: 'Subject knowledge',
                    details: {
                      id: 'subject_knowledge_details',
                      text: 'Subject knowledge bad',
                    },
                  },
                ],
              },
            ],
          }
        end

        it 'returns the related rejections in history items' do
          history_items = described_class.all_previous_applications(current_application_form, :subject_knowledge)

          history_item = history_items.first
          expect(history_items.count).to eq(1)
          expect(history_item.provider_name).to eq(application_choice1.provider.name)
          expect(history_item.section).to eq(:subject_knowledge)
          expect(history_item.feedback.flat_map(&:details).map(&:text)).to contain_exactly('Subject knowledge bad')
          expect(history_item.feedback_type).to eq('rejection_reasons')
        end
      end
    end

    it 'ignores application choices with no relevant feedback' do
      previous_application_form = create(:application_form)
      choice = create(:application_choice, :with_old_structured_rejection_reasons, application_form: previous_application_form)
      create(:application_choice, structured_rejection_reasons: { 'safeguarding_y_n' => 'No' }, application_form: previous_application_form)
      create(:application_choice, application_form: previous_application_form)
      current_application_form = duplicate_application!(previous_application_form)

      history_items = described_class.all_previous_applications(current_application_form, :becoming_a_teacher)

      expect(history_items).to contain_exactly(
        described_class::HistoryItem.new(choice.provider.name, :becoming_a_teacher, 'Use a spellchecker', 'reasons_for_rejection'),
      )
    end

    context 'for vendor_api rejection reasons' do
      let(:previous_application_form) { create(:application_form) }
      let!(:application_choice1) { create(:application_choice, :with_vendor_api_rejection_reasons, application_form: previous_application_form, structured_rejection_reasons: rejection_reasons) }
      let(:current_application_form) { duplicate_application!(previous_application_form) }
      let!(:application_choice2) { create(:application_choice, :with_vendor_api_rejection_reasons, application_form: current_application_form) }

      context 'when no reasons for section selected' do
        let(:rejection_reasons) { { selected_reasons: [{ id: 'course_full', label: 'Course full' }] } }

        it 'returns nothing' do
          history_items = described_class.all_previous_applications(current_application_form, :becoming_a_teacher)

          expect(history_items).to be_empty
        end
      end

      context 'when reasons selected for the `becoming_a_teacher` section' do
        let(:rejection_reasons) do
          {
            selected_reasons: [
              {
                id: 'personal_statement',
                label: 'Personal statement',
                details: {
                  id: 'personal_statement_details',
                  text: 'Personal statement bad',
                },
              },
            ],
          }
        end

        it 'returns the related rejections in history items' do
          history_items = described_class.all_previous_applications(current_application_form, :becoming_a_teacher)

          history_item = history_items.first
          expect(history_items.count).to eq(1)
          expect(history_item.provider_name).to eq(application_choice1.provider.name)
          expect(history_item.section).to eq(:becoming_a_teacher)
          expect(history_item.feedback.flat_map(&:details).map(&:text)).to contain_exactly('Personal statement bad')
          expect(history_item.feedback_type).to eq('vendor_api_rejection_reasons')
        end
      end
    end

  private

    def duplicate_application!(application_form)
      DuplicateApplication.new(application_form).duplicate
    end
  end
end
