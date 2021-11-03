require 'rails_helper'

RSpec.describe DataAPI::TADSubjectsExport do
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

      expect(result).to match_array([
        {
          subject: 'Mathematics',
          domicile: 'UK',
          nationality: 'EU',
          adjusted_applications: 1,
          adjusted_offers: 0,
          pending_conditions: 0,
          recruited: 0,
        }
      ])
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

      expect(result).to match_array([
        {
          subject: 'Mathematics',
          domicile: 'UK',
          nationality: 'EU',
          adjusted_applications: 0,
          adjusted_offers: 0.5,
          pending_conditions: 0,
          recruited: 0,
        },
        {
          subject: 'Physics',
          domicile: 'UK',
          nationality: 'EU',
          adjusted_applications: 0,
          adjusted_offers: 0.5,
          pending_conditions: 0,
          recruited: 0,
        },
      ])
    end

    def create_application(
      nationality:,
      domicile:,
      application_choice_attrs:
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
                create(:course_subject, subject: create(:subject, name: name))
              end,
            )
          )
        )
      end

      create(
        :completed_application_form,
        first_nationality: nationality,
        country: domicile,
        application_choices: application_choices,
      )
    end
  end
end
