require 'dfe/reference_data/hardcoded_reference_list'

module DfE
  module ReferenceData
    module International
      module Grades
        INTERNATIONAL_GRADES_SCHEMA = {
          id: :string,
          likely_above_level_four: { kind: :array, element_schema: :string },
          likely_below_level_four: { kind: :array, element_schema: :string },
          type: :string,
          hint: :string,
        }.freeze

        GRADES = HardcodedReferenceList.new(
          {
            '291628dc-38ee-4ff9-864d-ef9f830d75b8' => {
              likely_above_level_four: %w[A1 B2 B3 C4 C5 C6],
              likely_below_level_four: %w[D7 E8 F9],
              description: 'Letter and number grade',
              hint: nil,
            },
            '8806ef77-33ca-4003-812c-f059d0a56c9f' => {
              likely_above_level_four: %w[A A− B+ B B− C+ C C−],
              likely_below_level_four: %w[D+ D D− E],
              description: 'Letter grade',
              hint: nil,
            },
            '28c6a18a-2040-43af-8cf2-83b7e14ba14c' => {
              likely_above_level_four: %w[A1 A2 B1 B2 C1 C2],
              likely_below_level_four: %w[D1 D2 E],
              description: 'Letter and number grade',
              hint: 'For example, B2',
            },
            'cf71151e-df9d-465b-ad9f-d129764a0165' => {
              likely_above_level_four: (51..100).to_a.map { |n| "#{n}%" },
              likely_below_level_four: (0..50).to_a.map { |n| "#{n}%" },
              description: 'Percentage',
              hint: 'For example, 70%',
            },
            'bad86f85-e46d-413f-8d6c-525e6ecc0d8b' => {
              likely_above_level_four: %w[A1 A2 B1 B2 C1 C2 D1 D2 E],
              likely_below_level_four: %w[],
              description: 'Letter and number grade',
              hint: 'For example, B2',
            },
            'dce2ff0f-018e-436f-9439-79c65ae2ed26' => {
              likely_above_level_four: (0..100).to_a.map { |n| "#{n}%" },
              likely_below_level_four: %w[],
              description: 'Percentage',
              hint: 'For example, 70%',
            },

          },
          schema: INTERNATIONAL_GRADES_SCHEMA,
        )
      end
    end
  end
end
