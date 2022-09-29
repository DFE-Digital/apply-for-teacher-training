require 'rails_helper'

RSpec.describe CandidateMailer, type: :mailer do
  subject(:mailer) { described_class }

  let(:recruitment_cycle_year) { ApplicationForm::OLD_REFERENCE_FLOW_CYCLE_YEAR }
  let(:application_choice) { create(:application_choice) }
  let(:application_form) { create(:completed_application_form, :with_gcses, recruitment_cycle_year: recruitment_cycle_year, application_references: references, references_count: references.count, application_choices: [application_choice]) }
  let(:reference) { create(:reference, name: 'Scott Knowles') }
  let(:references) { [reference] }
  let(:course_option) do
    create(
      :course_option,
      course: create(
        :course,
        name: 'Mathematics',
        code: 'M101',
        start_date: Time.zone.local(2021, 9, 6),
        provider: create(
          :provider,
          name: 'Arithmetic College',
        ),
      ),
    )
  end

  describe '.chase_reference' do
    let(:referee) { create(:reference, name: 'Jolyne Doe', application_form: application_form) }
    let(:email) { mailer.chase_reference(referee) }

    it_behaves_like(
      'a mail with subject and content',
      I18n.t!('candidate_mailer.chase_reference.subject', referee_name: 'Jolyne Doe'),
      'heading' => 'Jolyne Doe has not responded yet',
    )

    context 'when the new references flow is active' do
      let(:recruitment_cycle_year) { ApplicationForm::OLD_REFERENCE_FLOW_CYCLE_YEAR + 1 }
      let(:application_choice) { create(:application_choice, :pending_conditions, course_option: course_option) }

      before do
        FeatureFlag.activate(:new_references_flow)
      end

      it 'includes content relating to the new flow' do
        expect(email.body).to include('You asked Jolyne Doe for a reference for your teacher training application. They have not replied yet.')
        expect(email.body).to include('Arithmetic College must check your references before they can confirm your place on the course. Contact them if you need help getting references or choosing who to ask.')
      end
    end
  end

  describe '.new_referee_request' do
    let(:referee) { create(:reference, name: 'Jolyne Doe', application_form: application_form) }
    let(:email) { mailer.send(:new_referee_request, referee, reason:) }

    context 'when referee has not responded' do
      let(:reason) { :not_responded }

      it_behaves_like(
        'a mail with subject and content',
        I18n.t!('candidate_mailer.new_referee_request.not_responded.subject', referee_name: 'Jolyne Doe'),
        'heading' => 'Jolyne Doe has not responded yet',
      )

      context 'when the new references flow is active' do
        let(:recruitment_cycle_year) { ApplicationForm::OLD_REFERENCE_FLOW_CYCLE_YEAR + 1 }
        let(:application_choice) { create(:application_choice, :pending_conditions, course_option: course_option) }

        before do
          FeatureFlag.activate(:new_references_flow)
        end

        it 'includes content relating to the new flow' do
          expect(email.body).to include('You asked Jolyne Doe for a reference for your teacher training application. They have not replied yet.')
          expect(email.body).to include('It’s important that Arithmetic College receives your references as soon as possible.')
        end
      end
    end

    context 'when referee has refused' do
      let(:reason) { :refused }

      it_behaves_like(
        'a mail with subject and content',
        I18n.t!('candidate_mailer.new_referee_request.refused.subject', referee_name: 'Jolyne Doe'),
        body: 'Jolyne Doe has declined your reference request',
      )

      context 'when the new references flow is active' do
        let(:recruitment_cycle_year) { ApplicationForm::OLD_REFERENCE_FLOW_CYCLE_YEAR + 1 }
        let(:application_choice) { create(:application_choice, :pending_conditions, course_option: course_option) }

        before do
          FeatureFlag.activate(:new_references_flow)
        end

        it 'includes content relating to the new flow' do
          expect(email.body).to include('Jolyne Doe has said that they’re unable to give you a reference.')
          expect(email.body).to include('It’s important that Arithmetic College receives your references as soon as possible.')
        end
      end
    end

    context 'when email address of referee has bounced' do
      let(:reason) { :email_bounced }

      it_behaves_like(
        'a mail with subject and content',
        I18n.t!('candidate_mailer.new_referee_request.email_bounced.subject', referee_name: 'Jolyne Doe'),
        body: 'Your referee request did not reach Jolyne Doe',
      )

      context 'when the new references flow is active' do
        let(:recruitment_cycle_year) { ApplicationForm::OLD_REFERENCE_FLOW_CYCLE_YEAR + 1 }
        let(:application_choice) { create(:application_choice, :pending_conditions, course_option: course_option) }

        before do
          FeatureFlag.activate(:new_references_flow)
        end

        it 'includes content relating to the new flow' do
          expect(email.body).to include('You asked Jolyne Doe for a reference for your teacher training application.')
          expect(email.body).to include('Your request did not reach Jolyne Doe. This could be because:')
        end
      end
    end
  end

  describe '.reference_received' do
    let(:email) do
      mailer.send(
        :reference_received,
        application_form.application_references.first,
      )
    end
    let(:reference) do
      build(:reference, :feedback_provided, name: 'Scott Knowles')
    end

    context 'when one reference has been received' do
      let(:application_form) do
        create(:application_form, :minimum_info, :with_gcses, recruitment_cycle_year: recruitment_cycle_year, application_references: references, application_choices: [application_choice])
      end
      let(:references) { [reference] }

      it_behaves_like(
        'a mail with subject and content',
        'Scott Knowles has given you a reference',
        'request other' => 'You need another reference',
      )
    end

    context 'when a second reference is received but none are selected' do
      let(:email) { mailer.send(:reference_received, reference) }

      let(:application_form) { build(:application_form) }
      let(:reference) { build(:reference, :feedback_provided, name: 'Scott Knowles', application_form:) }
      let(:other_reference) { build(:reference, :feedback_provided, name: 'William Adama', application_form:) }

      before do
        application_form.application_references = [reference, other_reference]
      end

      it_behaves_like(
        'a mail with subject and content',
        'Scott Knowles has given you a reference',
        'request other' => 'You have enough references to send your application to training providers.',
      )
    end

    context 'when a third reference is received but none are selected' do
      let(:email) { mailer.send(:reference_received, reference) }

      let(:application_form) { build(:application_form) }
      let(:reference) { build(:reference, :feedback_provided, name: 'Scott Knowles', application_form:) }
      let(:second_reference) { build(:reference, :feedback_provided, name: 'William Adama', application_form:) }
      let(:third_reference) { build(:reference, :feedback_provided, name: 'Kara Thrace', application_form:) }

      before do
        application_form.application_references = [reference, second_reference, third_reference]
      end

      it_behaves_like(
        'a mail with subject and content',
        'Scott Knowles has given you a reference',
        'request other' => 'You have more than enough references to send your application to training providers.',
      )
    end

    context 'when two references have been selected and another is received' do
      let(:email) { mailer.send(:reference_received, reference) }

      let(:application_form) { build(:application_form) }

      let(:first_selected_reference) { build(:reference, :feedback_provided, selected: true, application_form:) }
      let(:second_selected_reference) { build(:reference, :feedback_provided, selected: true, application_form:) }
      let(:reference) { build(:reference, :feedback_provided, name: 'Scott Knowles', application_form:) }

      before do
        application_form.application_references = [first_selected_reference, second_selected_reference]
      end

      it_behaves_like(
        'a mail with subject and content',
        'Scott Knowles has given you a reference',
        'request other' => 'You’ve selected 2 references to submit with your application already',
      )
    end

    context 'when the new references flow is active' do
      let(:reference) { create(:reference, :feedback_provided, name: 'Scott Knowles') }
      let(:recruitment_cycle_year) { ApplicationForm::OLD_REFERENCE_FLOW_CYCLE_YEAR + 1 }

      before do
        FeatureFlag.activate(:new_references_flow)
      end

      context 'when the candidate is pending conditions' do
        let(:application_choice) { create(:application_choice, :pending_conditions, course_option: course_option) }

        it 'includes content relating to the new flow' do
          expect(email.body).to include('Arithmetic College has received a reference for you from Scott Knowles')
          expect(email.body).to include('You can sign into your account to check the progress of your reference requests and offer conditions.')
        end
      end

      context 'when the candidate is recruited' do
        let(:application_choice) { create(:application_choice, :with_recruited, course_option: course_option) }

        it 'includes content relating to the new flow' do
          expect(email.body).to include('Arithmetic College has received a reference for you from Scott Knowles')
          expect(email.body).to include('You can sign into your account to check the progress of your reference requests.')
        end
      end
    end
  end
end
