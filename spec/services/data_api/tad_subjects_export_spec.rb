require 'rails_helper'

RSpec.describe DataAPI::TADSubjectsExport do
  it_behaves_like 'a data export'

  describe '#data_for_export' do
    before do
      @application_form = create(
        :completed_application_form,
        first_nationality: 'French',
        country: 'GB',
        application_choices: [
          create(
            :application_choice,
            status: :rejected,
            course_option: create(
              :course_option,
              course: create(
                :course,
                course_subjects: [
                  create(
                    :course_subject,
                    subject: create(
                      :subject,
                      name: 'Mathematics',
                    )
                  ),
                ]
              )
            )
          )
        ]
      )
    end

    it 'returns statistics for a counts application' do
      result = described_class.new.data_for_export

      expect(result).to eq([
        {
          'subjects' => '{Mathematics}',
          'status' => 'rejected',
          'nationality' => 'EU',
          'domicile' => 'UK',
          'count' => 1,
        }
      ])
    end
  end
end
