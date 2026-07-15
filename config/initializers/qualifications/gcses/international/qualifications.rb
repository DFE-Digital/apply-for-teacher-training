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
            '5efvvc3b-401e-45b1-ax16-yz14e0927qu' => {
              name: 'CBSE Class 10 (AISSE)',
              countries: %w[IN],
              grade_options: %w[28c6a18a-2040-43af-8cf2-83b7e14ba14c cf71151e-df9d-465b-ad9f-d129764a0165],
            },
            '61a9a7ec-d7ef-469f-b370-33c8b97318a9' => {
              name: 'ICSE (Indian Certificate of Secondary Education)',
              countries: %w[IN],
              grade_options: %w[28c6a18a-2040-43af-8cf2-83b7e14ba14c cf71151e-df9d-465b-ad9f-d129764a0165],
            },

          },
          schema: INTERNATIONAL_QUALIFICATIONS_SCHEMA,
        )
      end
    end
  end
end
