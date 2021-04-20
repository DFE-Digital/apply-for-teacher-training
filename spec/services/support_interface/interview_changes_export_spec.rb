require 'rails_helper'

RSpec.describe SupportInterface::InterviewChangesExport do
  let!(:now) { Time.zone.now.change(usec: 0) }
  let(:interview) { create(:interview, date_and_time: 1.day.from_now) }

  around do |example|
    Timecop.freeze(now) { example.run }
  end

  describe '#data_for_export' do
    let!(:create_interview_audit) do
      create(
        :interview_audit,
        interview: interview,
        changes: {
          'location' => interview.location,
          'provider_id' => interview.provider_id,
          'cancelled_at' => nil,
          'date_and_time' => interview.date_and_time.to_s,
          'additional_details' => nil,
          'cancellation_reason' => nil,
          'application_choice_id' => interview.application_choice_id,
        },
        action: 'create',
        created_at: 2.days.ago,
      )
    end
    let!(:edit_interview_audit) do
      create(
        :interview_audit,
        interview: interview,
        changes: {
          'location' => [interview.location, 'Google Meet'],
          'date_and_time' => [interview.date_and_time.to_s, 2.days.from_now.to_s],
          'additional_details' => [nil, 'Wear a bowtie'],
        },
        action: 'update',
        created_at: 1.day.ago,
      )
    end
    let!(:orphaned_audit) do
      # This represents an audit for a hard-deleted interview, and should be ignored in the export
      create(
        :interview_audit,
        auditable_id: 123,
        action: 'create',
        created_at: 2.days.ago,
      )
    end

    it_behaves_like 'a data export'

    it 'returns a list of hashes with the correct values' do
      expect(described_class.new.data_for_export).to match_array([
        {
          audit_id: create_interview_audit.id,
          audit_created_at: create_interview_audit.created_at,
          audit_type: 'create',
          interview_id: interview.id,
          candidate_id: interview.application_choice.candidate.id,
          application_choice_id: interview.application_choice.id,
          provider_code: interview.application_choice.provider.code,
          provider_user: create_interview_audit.user.email_address,
          interview_preferences: interview.application_choice.application_form.interview_preferences,
          application_submitted_at: interview.application_choice.application_form.submitted_at,
          course_code: interview.application_choice.course.code,
          course_location: interview.application_choice.site.name_and_code,
          date_and_time: 1.day.from_now.to_s,
          cancelled_at: nil,
          cancellation_reason: nil,
          provider_id: interview.provider_id,
          location: interview.location,
          additional_details: nil,
        },
        {
          audit_id: edit_interview_audit.id,
          audit_created_at: edit_interview_audit.created_at,
          audit_type: 'update',
          interview_id: interview.id,
          candidate_id: interview.application_choice.candidate.id,
          application_choice_id: interview.application_choice.id,
          provider_code: interview.application_choice.provider.code,
          provider_user: edit_interview_audit.user.email_address,
          interview_preferences: interview.application_choice.application_form.interview_preferences,
          application_submitted_at: interview.application_choice.application_form.submitted_at,
          course_code: interview.application_choice.course.code,
          course_location: interview.application_choice.site.name_and_code,
          date_and_time: 2.days.from_now.to_s,
          cancelled_at: '',
          cancellation_reason: '',
          provider_id: '',
          location: 'Google Meet',
          additional_details: 'Wear a bowtie',
        },
      ])
    end
  end

  describe '#row_for_audit' do
    let(:user) { create(:provider_user) }
    let(:username) { nil }
    let(:changes) do
      {
        'location' => 'Zoom',
        'provider_id' => '1234',
        'cancelled_at' => nil,
        'date_and_time' => 1.day.from_now.to_s,
        'additional_details' => nil,
        'cancellation_reason' => nil,
        'application_choice_id' => interview.application_choice_id,
      }
    end
    let(:action) { 'create' }
    let(:audit_created_at) { 1.hour.ago }
    let(:audit) do
      create(
        :interview_audit,
        interview: interview,
        user: user,
        username: username,
        changes: changes,
        action: action,
        created_at: audit_created_at,
      )
    end
    let(:row) { described_class.new.row_for_audit(audit) }

    context 'when audit creates an interview' do
      it 'sets the audit_type to create' do
        expect(row[:audit_type]).to eq('create')
      end

      it 'sets correct initial interview attributes' do
        expect(row[:provider_id]).to eq('1234')
        expect(row[:date_and_time]).to eq(1.day.from_now.to_s)
        expect(row[:cancelled_at]).to be_blank
        expect(row[:cancellation_reason]).to be_blank
        expect(row[:location]).to eq('Zoom')
        expect(row[:additional_details]).to be_blank
      end
    end

    context 'when audit edits an interview' do
      let(:action) { 'update' }
      let(:changes) do
        {
          'location' => ['Zoom', 'Google Meet'],
          'date_and_time' => [1.day.from_now.to_s, 2.days.from_now.to_s],
          'additional_details' => [nil, 'Wear a bowtie'],
        }
      end

      it 'sets the audit_type to update' do
        expect(row[:audit_type]).to eq('update')
      end

      it 'sets correct interview attributes' do
        expect(row[:provider_id]).to be_blank
        expect(row[:date_and_time]).to eq(2.days.from_now.to_s)
        expect(row[:cancelled_at]).to be_blank
        expect(row[:cancellation_reason]).to be_blank
        expect(row[:location]).to eq('Google Meet')
        expect(row[:additional_details]).to eq('Wear a bowtie')
      end
    end

    context 'when audit cancels an interview' do
      let(:action) { 'update' }
      let(:changes) do
        {
          'cancelled_at' => [nil, 1.hour.ago.to_s],
          'cancellation_reason' => [nil, 'No reply to our email'],
        }
      end

      it 'sets correct interview attributes' do
        expect(row[:provider_id]).to be_blank
        expect(row[:date_and_time]).to be_blank
        expect(row[:cancelled_at]).to eq(1.hour.ago.to_s)
        expect(row[:cancellation_reason]).to eq('No reply to our email')
        expect(row[:location]).to be_blank
        expect(row[:additional_details]).to be_blank
      end
    end

    context 'when audit edits an interview that would have already occurred' do
      let(:interview) { create(:interview, date_and_time: 1.day.ago) }
      let(:action) { 'update' }
      let(:changes) do
        {
          'date_and_time' => [1.day.ago.to_s, 2.days.from_now.to_s],
          'location' => ['Zoom', 'New Zoom link'],
        }
      end

      it 'sets correct interview attributes' do
        expect(row[:provider_id]).to be_blank
        expect(row[:date_and_time]).to eq(2.days.from_now.to_s)
        expect(row[:cancelled_at]).to be_blank
        expect(row[:cancellation_reason]).to be_blank
        expect(row[:location]).to eq('New Zoom link')
        expect(row[:additional_details]).to be_blank
      end
    end

    describe 'application related columns' do
      it 'returns columns relating to the application' do
        expect(row[:candidate_id]).to eq(interview.application_choice.candidate.id)
        expect(row[:application_choice_id]).to eq(interview.application_choice_id)
        expect(row[:provider_code]).to eq(interview.application_choice.provider.code)
        expect(row[:interview_preferences]).to eq(interview.application_choice.application_form.interview_preferences)
        expect(row[:application_submitted_at]).to eq(interview.application_choice.application_form.submitted_at)
        expect(row[:course_code]).to eq(interview.application_choice.course.code)
        expect(row[:course_location]).to eq(interview.application_choice.site.name_and_code)
      end
    end

    describe 'provider_user' do
      context 'when the change is made by a provider user' do
        it 'sets provider_user to the email address of the user' do
          expect(row[:provider_user]).to eq(user.email_address)
        end
      end

      context 'when the change is made by a support user' do
        let(:user) { create(:support_user) }

        it 'sets provider_user to Support' do
          expect(row[:provider_user]).to eq('Support')
        end
      end

      context 'when the change was done in the rails console' do
        let(:user) { nil }
        let(:username) { 'Ben 10 via the Rails console' }

        it 'sets provider_user to Automated process' do
          expect(row[:provider_user]).to eq('Support')
        end
      end

      context 'when the change does not have an associated user' do
        let(:user) { nil }

        it 'sets provider_user to Automated process' do
          expect(row[:provider_user]).to eq('Automated process')
        end
      end
    end
  end
end
