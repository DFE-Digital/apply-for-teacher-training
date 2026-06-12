require 'dfe/reference_data/hardcoded_reference_list'

module DfE
  module ReferenceData
    module International
      module Qualifications
        INTERNATIONAL_QUALIFICATIONS_SCHEMA = {
          id: :string,
          name: :string,
          countries: { kind: :array, element_schema: :string },
          grade_options: { kind: :array, element_schema: :strings },
        }.freeze

        QUALIFICATIONS = HardcodedReferenceList.new(
          {
            '6eeffc3b-461e-45b9-a4e6-ad040e2710ce' => {
              name: 'WASSCE (West African Senior School Certificate Examination)',
              countries: %w[NG GH SL GM LR],
              grade_options: %w[291628dc-38ee-4ff9-864d-ef9f830d75b8],
            },
            'ff63cd78-8c54-4801-b92b-ca5a95891ebe' => {
              name: 'KCSE (Kenya Certificate of Secondary Education)',
              countries: %w[KE],
              grade_options: %w[8806ef77-33ca-4003-812c-f059d0a56c9f],
            },
          },
          schema: INTERNATIONAL_QUALIFICATIONS_SCHEMA,
        )
      end
    end
  end
end
