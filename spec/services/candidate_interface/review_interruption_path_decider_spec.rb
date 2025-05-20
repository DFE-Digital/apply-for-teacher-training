require 'rails_helper'

RSpec.describe CandidateInterface::ReviewInterruptionPathDecider do
  include Rails.application.routes.url_helpers

  let(:application_form) { create(:application_form, :completed, submitted_at: nil) }
  let(:application_choice) { create(:application_choice, application_form:) }

  context 'personal statement needs review', time: mid_cycle do
    before do
      application_form.update(becoming_a_teacher: Faker::Lorem.paragraph_by_chars(number: 499))
    end

    context 'starts with initial step' do
      let(:current_step) { :initial_step }

      it 'returns personal statement path' do
        result = described_class.decide_path(application_choice, current_step:)
        expect(result).to eq(
          candidate_interface_course_choices_course_review_interruption_path(
            application_choice.id,
          ),
        )
      end
    end

    context 'starts with personal statement step' do
      let(:current_step) { :short_personal_statement }

      it 'returns review and submit path' do
        result = described_class.decide_path(application_choice, current_step:)
        expect(result).to eq(
          candidate_interface_course_choices_course_review_and_submit_path(
            application_choice.id,
          ),
        )
      end
    end

    context 'starts after personal statement step' do
      let(:current_step) { :undergraduate_course_with_degree }

      it 'returns review and submit path' do
        result = described_class.decide_path(application_choice, current_step:)
        expect(result).to eq(
          candidate_interface_course_choices_course_review_and_submit_path(
            application_choice.id,
          ),
        )
      end
    end

    it 'returns does not return interruption for current step' do
      result = described_class.decide_path(application_choice, current_step: :short_personal_statement)

      expect(result).to eq(
        candidate_interface_course_choices_course_review_and_submit_path(
          application_choice.id,
        ),
      )
    end

    it 'returns interruption for next step' do
      result = described_class.decide_path(application_choice, current_step: :initial_step)
      expect(result).to eq(
        candidate_interface_course_choices_course_review_interruption_path(
          application_choice.id,
        ),
      )
    end
  end

  context 'undergraduate course selected with degree needs review' do
    before do
      create(:degree_qualification, application_form:)
      course_option = create(:course_option, course: build(:course, :teacher_degree_apprenticeship))
      application_choice.update(current_course_option: course_option)
    end

    context 'starts with personal statement step' do
      let(:current_step) { :short_personal_statement }

      it 'returns undergraduate course with degree interruption path' do
        result = described_class.decide_path(application_choice, current_step:)
        expect(result).to eq(
          candidate_interface_course_choices_course_review_undergraduate_interruption_path(
            application_choice.id,
          ),
        )
      end
    end

    context 'starts with undergraduate course with degree step' do
      let(:current_step) { :undergraduate_course_with_degree }

      it 'returns review and submit path' do
        result = described_class.decide_path(application_choice, current_step:)
        expect(result).to eq(
          candidate_interface_course_choices_course_review_and_submit_path(
            application_choice.id,
          ),
        )
      end
    end
  end

  context 'enic interruption review required' do
    before do
      create(
        :non_uk_degree_qualification,
        application_form:,
        enic_reference: nil,
        enic_reason: %w[waiting not_needed maybe].sample,
      )
    end

    context 'starts with undergraduate course degree step' do
      let(:current_step) { :undergraduate_course_with_degree }

      it 'returns enic interruption path' do
        result = described_class.decide_path(application_choice, current_step:)
        expect(result).to eq(
          candidate_interface_course_choices_course_review_enic_interruption_path(
            application_choice.id,
          ),
        )
      end
    end

    context 'starts with enic step' do
      let(:current_step) { :enic }

      it 'returns review and submit path' do
        result = described_class.decide_path(application_choice, current_step:)
        expect(result).to eq(
          candidate_interface_course_choices_course_review_and_submit_path(
            application_choice.id,
          ),
        )
      end
    end
  end

  context 'eligible for reference interruption' do
    before do
      create(
        :application_reference,
        application_form:,
        referee_type: 'academic',
        email_address: 'someone_personal@gmail.com',
      )
    end

    context 'starts with enic step' do
      let(:current_step) { :enic }

      it 'returns references with personal email addresses interruption path' do
        result = described_class.decide_path(application_choice, current_step:)
        expect(result).to eq(
          candidate_interface_course_choices_course_review_references_interruption_path(
            application_choice.id,
          ),
        )
      end
    end

    context 'starts with references step' do
      let(:current_step) { :references_with_personal_email_addresses }

      it 'returns review and submit path' do
        result = described_class.decide_path(application_choice, current_step:)
        expect(result).to eq(
          candidate_interface_course_choices_course_review_and_submit_path(
            application_choice.id,
          ),
        )
      end
    end
  end
end
