require 'rails_helper'

RSpec.describe ApplicationsExportForUCAS do
  let(:unsubmitted_form) { create(:application_form) }
  let(:submitted_form) { create(:completed_application_form, application_choices_count: 3) }

  describe '#relevant_applications' do
    let(:result) { ApplicationsExportForUCAS.new.send(:relevant_applications) }

    it 'includes ApplicationForms which are submitted' do
      expect(result).to include(submitted_form)
    end

    it 'does not include ApplicationForms which are unsubmitted' do
      expect(result).not_to include(unsubmitted_form)
    end

    it 'does not include submitted ApplicationForms where the candidate has hide_in_reporting set' do
      submitted_form.candidate.update(hide_in_reporting: true)
      expect(result).not_to include(submitted_form)
    end
  end

  describe '#applications' do
    let(:result) { ApplicationsExportForUCAS.new.applications }

    it 'returns an array' do
      expect(result).to be_a(Array)
    end

    context 'when a relevant application form exists with multiple application_choices' do
      let!(:application) do
        create(:completed_application_form, :with_equality_and_diversity_data, application_choices_count: 3)
      end

      it 'returns one element for each choice on the form' do
        expect(result.size).to eq(3)
      end

      it 'returns all Hashes' do
        expect(result).to all(be_a(Hash))
      end

      it 'returns the application details with the expected names' do
        expect(result).to all match(
          a_hash_including(
            apply_candidate_id: application.candidate_id,
            first_name: application.first_name,
            surname: application.last_name,
            dob: application.date_of_birth.iso8601,
            address_line_1: application.address_line1,
            address_line_2: application.address_line2,
            address_line_3: application.address_line3,
            address_line_4: application.address_line4,
            country: application.country,
            postcode: application.postcode,
            email_address: application.candidate.email_address,
            phase: application.phase,
          ),
        )
      end

      it 'returns the correct details from each choice with the expected names' do
        expect(result.map { |e| e[:provider_code] }.sort).to eq(application.application_choices.map { |e| e.provider.code }.sort)
        expect(result.map { |e| e[:provider_name] }.sort).to eq(application.application_choices.map { |e| e.provider.name }.sort)
        expect(result.map { |e| e[:programme_type] }.sort).to eq(application.application_choices.map { |e| e.course.funding_type }.sort)
        expect(result.map { |e| e[:programme_outcome] }.sort).to eq(application.application_choices.map { |e| e.course.description }.sort)
        expect(result.map { |e| e[:nctl_subject] }.sort).to eq(application.application_choices.map { |e| e.course.subject_codes.join('|') }.sort)
        expect(result.map { |e| e[:course_name] }.sort).to eq(application.application_choices.map { |e| e.course.name }.sort)
        expect(result.map { |e| e[:course_code] }.sort).to eq(application.application_choices.map { |e| e.course.code }.sort)
        expect(result.map { |e| e[:application_state] }.sort).to eq(application.application_choices.map(&:status).sort)
        expect(result.map { |e| e[:level] }.sort).to eq(application.application_choices.map { |e| e.course.level }.sort)
      end

      it 'includes the correct equality_and_diversity data' do
        expect(result.first[:sex]).to eq(application.equality_and_diversity['sex'])
        expect(result.first[:ethnic_background]).to eq(application.equality_and_diversity['ethnic_background'])
        expect(result.first[:ethnic_group]).to eq(application.equality_and_diversity['ethnic_group'])
        expect(result.first[:disability_status]).to eq(application.equality_and_diversity['disability_status'])
        expect(result.first[:disabilities]).to eq(application.equality_and_diversity['disabilities'].join('|'))
        expect(result.first[:other_disability]).to eq(application.equality_and_diversity['other_disability'])
      end
    end
  end
end
