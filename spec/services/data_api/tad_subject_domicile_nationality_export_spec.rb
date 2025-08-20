require 'rails_helper'

RSpec.describe DataAPI::TADSubjectDomicileNationalityExport do
  it_behaves_like 'a data export'

  describe '#data_for_export' do
    it 'returns counts for a single application' do
      create_application(
        nationality: 'French',
        domicile: 'GB',
        application_choice_attrs: [
          { status: :rejected, subjects: ['Mathematics'] },
        ],
      )

      result = described_class.new.data_for_export

      expect(result).to contain_exactly(
        {
          subject: 'Mathematics',
          candidate_domicile: 'UK',
          candidate_nationality: 'EU',
          adjusted_applications: 1,
          adjusted_offers: 0,
          pending_conditions: 0,
          recruited: 0,
        },
      )
    end

    it 'returns statistics for an application with split subjects' do
      create_application(
        nationality: 'French',
        domicile: 'GB',
        application_choice_attrs: [
          { status: :rejected, subjects: ['Mathematics'] },
          { status: :offer, subjects: ['Physics'] },
          { status: :offer, subjects: ['Mathematics'] },
        ],
      )

      result = described_class.new.data_for_export

      expect(result).to contain_exactly(
        {
          subject: 'Mathematics',
          candidate_domicile: 'UK',
          candidate_nationality: 'EU',
          adjusted_applications: 0,
          adjusted_offers: 1,
          pending_conditions: 0,
          recruited: 0,
        },
        {
          subject: 'Physics',
          candidate_domicile: 'UK',
          candidate_nationality: 'EU',
          adjusted_applications: 0,
          adjusted_offers: 1,
          pending_conditions: 0,
          recruited: 0,
        },
      )
    end

    it 'returns statistics for apply 1 and latest apply 2 application only' do
      apply_1_application_form = create_application(
        nationality: 'French',
        domicile: 'GB',
        application_choice_attrs: [
          { status: :rejected, subjects: ['Mathematics'] },
          { status: :rejected, subjects: ['Physics'] },
          { status: :withdrawn, subjects: ['Mathematics'] },
        ],
      )
      second_application_form = create_application(
        nationality: 'French',
        domicile: 'GB',
        application_choice_attrs: [
          { status: :rejected, subjects: ['Mathematics'] },
        ],
        previous_application_form: apply_1_application_form,
      )
      create_application(
        nationality: 'French',
        domicile: 'GB',
        application_choice_attrs: [
          { status: :offer, subjects: ['Mathematics'] },
        ],
        previous_application_form: second_application_form,
      )

      result = described_class.new.data_for_export

      expect(result).to contain_exactly(
        {
          subject: 'Mathematics',
          candidate_domicile: 'UK',
          candidate_nationality: 'EU',
          adjusted_applications: 1,
          adjusted_offers: 1,
          pending_conditions: 0,
          recruited: 0,
        },
        {
          subject: 'Physics',
          candidate_domicile: 'UK',
          candidate_nationality: 'EU',
          adjusted_applications: 1,
          adjusted_offers: 0,
          pending_conditions: 0,
          recruited: 0,
        },
      )
    end

    it 'returns statistics for multiple applications' do
      create_application(
        nationality: 'French',
        domicile: 'GB',
        application_choice_attrs: [
          { status: :rejected, subjects: ['Mathematics'] },
          { status: :offer, subjects: ['Physics'] },
          { status: :offer, subjects: ['Mathematics'] },
        ],
      )
      create_application(
        nationality: 'French',
        domicile: 'GB',
        application_choice_attrs: [
          { status: :rejected, subjects: ['Mathematics'] },
          { status: :recruited, subjects: ['Physics'] },
          { status: :offer, subjects: ['Mathematics'] },
        ],
      )
      create_application(
        nationality: 'Welsh',
        domicile: 'GB',
        application_choice_attrs: [
          { status: :rejected, subjects: ['English'] },
          { status: :awaiting_provider_decision, subjects: ['Chemistry'] },
          { status: :awaiting_provider_decision, subjects: ['Chemistry'] },
        ],
      )
      create_application(
        nationality: 'Scottish',
        domicile: 'GB',
        application_choice_attrs: [
          { status: :rejected, subjects: ['English'] },
          { status: :withdrawn, subjects: ['Chemistry'] },
        ],
      )

      result = described_class.new.data_for_export

      expect(result).to contain_exactly(
        {
          subject: 'Mathematics',
          candidate_domicile: 'UK',
          candidate_nationality: 'EU',
          adjusted_applications: 0,
          adjusted_offers: 1,
          pending_conditions: 0,
          recruited: 0,
        },
        {
          subject: 'Physics',
          candidate_domicile: 'UK',
          candidate_nationality: 'EU',
          adjusted_applications: 0,
          adjusted_offers: 1,
          pending_conditions: 0,
          recruited: 1,
        },
        {
          subject: 'English',
          candidate_domicile: 'UK',
          candidate_nationality: 'UK',
          adjusted_applications: 1,
          adjusted_offers: 0,
          pending_conditions: 0,
          recruited: 0,
        },
        {
          subject: 'Chemistry',
          candidate_domicile: 'UK',
          candidate_nationality: 'UK',
          adjusted_applications: 2,
          adjusted_offers: 0,
          pending_conditions: 0,
          recruited: 0,
        },
      )
    end

    def create_application(
      nationality:,
      domicile:,
      application_choice_attrs:,
      phase: 'apply_1',
      previous_application_form: nil
    )
      application_choices = application_choice_attrs.map do |attrs|
        create(
          :application_choice,
          status: attrs[:status],
          course_option: create(
            :course_option,
            course: create(
              :course,
              course_subjects: attrs[:subjects].map do |name|
                create(:course_subject, subject: create(:subject, name:))
              end,
            ),
          ),
        )
      end

      application_form_attrs = {
        first_nationality: nationality,
        country: domicile,
        application_choices:,
        phase:,
        previous_application_form_id: previous_application_form&.id,
      }
      application_form_attrs.merge!(candidate_id: previous_application_form&.candidate_id) if previous_application_form
      create(:completed_application_form, application_form_attrs)
    end
  end
end
