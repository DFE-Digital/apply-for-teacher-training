require 'dfe/reference_data/hardcoded_reference_list'

module DfE
  module ReferenceData
    module International
      module Grades
        INTERNATIONAL_GRADES_SCHEMA = {
          id: :string,
          passing_grades: { kind: :array, element_schema: :string },
          failing_grades: { kind: :array, element_schema: :string },
          type: :string,
          hint: :string,
        }.freeze

        GRADES = HardcodedReferenceList.new(
          {
            '291628dc-38ee-4ff9-864d-ef9f830d75b8' => {
              passing_grades: %w[A1 B2 B3 C4 C5 C6],
              failing_grades: %w[D7 E8 F9],
              type: 'Letter and number grade',
              hint: nil,
            },
            '8806ef77-33ca-4003-812c-f059d0a56c9f' => {
              passing_grades: %w[A A− B+ B B− C+ C C−],
              failing_grades: %w[D+ D D− E],
              type: 'Letter grade',
              hint: nil,
            },
            '28c6a18a-2040-43af-8cf2-83b7e14ba14c' => {
              passing_grades: %w[A1 A2 B1 B2 C1 C2],
              failing_grades: %w[D1 D2 E],
              type: 'Letter and number grade',
              hint: 'For example, B2',
            },
            'cf71151e-df9d-465b-ad9f-d129764a0165' => {
              passing_grades: (51..100).to_a.map { |n| "#{n}%" },
              failing_grades: (0..50).to_a.map { |n| "#{n}%" },
              type: 'Percentage',
              hint: 'For example, 70%',
            },

          },
          schema: INTERNATIONAL_GRADES_SCHEMA,
        )
      end
    end
  end
end
