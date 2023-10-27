require 'rails_helper'

RSpec.describe CandidateInterface::SectionPolicy do
  subject(:section_policy) do
    described_class.new(current_application:, controller_path:, action_name:, params:)
  end

  let(:current_application) { create(:application_form) }
  let(:controller_path) { '' }
  let(:action_name) { '' }
  let(:params) { {} }

  describe '#can_edit?' do
    context 'when candidate accepted an offer' do
      before do
        create(:application_choice, :accepted, application_form: current_application)
      end

      it 'returns true' do
        expect(section_policy.can_edit?).to be true
      end
    end

    context 'when candidate did not submitted yet' do
      it 'returns true' do
        expect(section_policy.can_edit?).to be true
      end
    end

    context 'when candidate already submitted at least once' do
      let(:application_form) { create(:application_form) }

      before do
        create(:application_choice, :awaiting_provider_decision, application_form: current_application)
      end

      context 'when accessing an editable section' do
        let(:controller_path) { 'candidate_interface/personal_details/review' }

        it 'returns true' do
          expect(section_policy.can_edit?).to be true
        end
      end

      context 'when accessing an non editable section' do
        let(:controller_path) { 'some-non-editable/controller' }

        it 'returns false' do
          expect(section_policy.can_edit?).to be false
        end
      end
    end

    context 'when candidates already submitted and adds a primary course choice and visits science GCSE' do
      let(:primary) { create(:course, level: 'primary') }
      let(:secondary) { create(:course, level: 'secondary') }
      let(:controller_path) { 'candidate_interface/gcse/review' }
      let(:params) { { subject: 'science' } }

      before do
        create(:application_choice, :awaiting_provider_decision, course_option: create(:course_option, course: secondary), application_form: current_application)
      end

      context 'when primary choice is submitted' do
        before do
          create(:application_choice, :awaiting_provider_decision, course_option: create(:course_option, course: primary), application_form: current_application)
        end

        it 'returns false' do
          expect(section_policy.can_edit?).to be false
        end
      end

      context 'when primary choice is unsubmitted' do
        before do
          create(:application_choice, :unsubmitted, course_option: create(:course_option, course: primary), application_form: current_application)
        end

        it 'returns true' do
          expect(section_policy.can_edit?).to be true
        end
      end

      context 'when primary choice is unsubmitted and user wants to edit grade' do
        let(:controller_path) { 'candidate_interface/gcse/science/grade' }
        let(:params) { {} }

        before do
          create(:application_choice, :unsubmitted, course_option: create(:course_option, course: primary), application_form: current_application)
        end

        it 'returns true' do
          expect(section_policy.can_edit?).to be true
        end
      end

      context 'when candidates visit another gcse page' do
        let(:params) { { subject: 'maths' } }

        it 'returns false' do
          expect(section_policy.can_edit?).to be false
        end
      end
    end

    context 'when application is temporarily editable via support' do
      before do
        allow(Rails.configuration.x.sections)
          .to receive(:[])
          .with('editable')
          .and_return(%i[personal_details])
        create(:application_choice, :awaiting_provider_decision, application_form: current_application)
      end

      context 'when editable maths GCSE' do
        let(:params) { { subject: 'maths' } }
        let(:controller_path) { 'candidate_interface/gcse/review' }
        let(:current_application) do
          create(:application_form, editable_sections: %w[maths_gcse], editable_until: 1.day.from_now)
        end

        it 'returns true' do
          expect(section_policy.can_edit?).to be true
        end
      end

      context 'when editable maths GCSE and user wants to edit grade' do
        let(:controller_path) { 'candidate_interface/gcse/maths/grade' }
        let(:params) { {} }
        let(:current_application) do
          create(:application_form, editable_sections: %w[maths_gcse], editable_until: 1.day.from_now)
        end

        it 'returns true' do
          expect(section_policy.can_edit?).to be true
        end
      end

      context 'when not editable maths GCSE' do
        let(:params) { { subject: 'maths' } }
        let(:controller_path) { 'candidate_interface/gcse/review' }

        let(:current_application) do
          create(:application_form, editable_sections: %w[degrees], editable_until: 1.day.from_now)
        end

        it 'returns false' do
          expect(section_policy.can_edit?).to be false
        end
      end

      context 'when editable english GCSE' do
        let(:params) { { subject: 'english' } }
        let(:controller_path) { 'candidate_interface/gcse/review' }

        let(:current_application) do
          create(:application_form, editable_sections: %w[english_gcse], editable_until: 1.day.from_now)
        end

        it 'returns true' do
          expect(section_policy.can_edit?).to be true
        end
      end

      context 'when editable english GCSE and user wants to edit grade' do
        let(:controller_path) { 'candidate_interface/gcse/english/grade' }
        let(:params) { {} }
        let(:current_application) do
          create(:application_form, editable_sections: %w[english_gcse], editable_until: 1.day.from_now)
        end

        it 'returns true' do
          expect(section_policy.can_edit?).to be true
        end
      end

      context 'when not editable english GCSE' do
        let(:params) { { subject: 'english' } }
        let(:controller_path) { 'candidate_interface/gcse/review' }
        let(:current_application) do
          create(:application_form, editable_sections: %w[degrees], editable_until: 1.day.from_now)
        end

        it 'returns false' do
          expect(section_policy.can_edit?).to be false
        end
      end

      context 'when editable science GCSE' do
        let(:params) { { subject: 'science' } }
        let(:controller_path) { 'candidate_interface/gcse/review' }

        let(:current_application) do
          create(:application_form, editable_sections: %w[science_gcse], editable_until: 1.day.from_now)
        end

        it 'returns true' do
          expect(section_policy.can_edit?).to be true
        end
      end

      context 'when editable english GCSE and candidate visit maths GCSE' do
        let(:params) { { subject: 'maths' } }
        let(:controller_path) { 'candidate_interface/gcse/review' }

        let(:current_application) do
          create(:application_form, editable_sections: %w[english_gcse], editable_until: 1.day.from_now)
        end

        it 'returns true' do
          expect(section_policy.can_edit?).to be false
        end
      end

      context 'when not editable science GCSE' do
        let(:params) { { subject: 'science' } }
        let(:controller_path) { 'candidate_interface/gcse/review' }
        let(:current_application) do
          create(:application_form, editable_sections: %w[degrees], editable_until: 1.day.from_now)
        end

        it 'returns false' do
          expect(section_policy.can_edit?).to be false
        end
      end

      context 'when a non editable section is temporarily editable via support' do
        let(:controller_path) { 'candidate_interface/degrees/degree' }
        let(:current_application) do
          create(:application_form, editable_sections: %w[degrees], editable_until: 1.day.from_now)
        end

        it 'returns true' do
          expect(section_policy.can_edit?).to be true
        end
      end

      context 'when a non editable section is not temporarily editable via support' do
        let(:controller_path) { 'candidate_interface/safeguarding' }
        let(:current_application) do
          create(:application_form, editable_sections: %w[degrees], editable_until: 1.day.from_now)
        end

        it 'returns false' do
          expect(section_policy.can_edit?).to be false
        end
      end

      context 'when the section is temporally editable but editable time expired' do
        let(:controller_path) { 'candidate_interface/degrees/degree' }
        let(:current_application) do
          create(:application_form, editable_sections: %w[degrees], editable_until: 1.day.ago)
        end

        it 'returns false' do
          expect(section_policy.can_edit?).to be false
        end
      end
    end
  end
end
