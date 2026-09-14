require 'dfe/reference_data/hardcoded_reference_list'

module DfE
  module ReferenceData
    module DegreeSubjectRelevancyGroups
      SUBJECT_GROUPS_SCHEMA = {
        id: :string,
        name: :string,
      }.freeze

      SUBJECT_GROUPS = HardcodedReferenceList.new(
        {
          '184896e8-4402-4211-85d3-9dff8259e294' => { name: 'Ancient Languages' },
          'a2028760-4423-483d-8e34-86583876848c' => { name: 'Art and design' },
          '4d782fe1-c896-436e-86b1-a6b6156780fd' => { name: 'Biology' },
          '232f0713-29e7-4701-a30a-98b1f3b29e46' => { name: 'Business studies' },
          'd7f1c6ec-0fca-40dc-ac40-42f4f612f330' => { name: 'Chemistry' },
          '2b4fe6c8-3a57-4b32-9fda-5f06f45a96af' => { name: 'Citizenship' },
          '9f1955aa-877e-424e-9781-964add16a289' => { name: 'Classics' },
          '16b8b6c4-0ca8-4b85-81eb-6a75eaaa3db3' => { name: 'Communication and media studies' },
          '74f15e5b-d9eb-4cd3-999d-b9de44882845' => { name: 'Computing' },
          '5985133d-921e-4777-b97c-4387607fcc5c' => { name: 'Dance' },
          '3cfa92d4-31ad-4714-b603-5ec408b99bb2' => { name: 'Design and technology' },
          '5412cd5e-7344-4ebb-8748-dc93e36e4685' => { name: 'Drama' },
          '3ca9e7ec-0cc5-47d6-8a4e-e47bf90f4186' => { name: 'Economics' },
          '7e9e52d0-09bc-4a78-88b6-7b22e8fda6ac' => { name: 'English' },
          '3e74e24c-656a-40f1-9bae-042213e5fb5f' => { name: 'Geography' },
          'ccdc5b0d-b26e-4609-97ce-75ffe45b55ae' => { name: 'Health and social care' },
          'b0c5eb9e-6354-490f-8595-e525af1e7975' => { name: 'History' },
          '9819461c-d4b5-43c5-bf87-b5c08c01e1ae' => { name: 'Mathematics' },
          '9c7f1516-4fc0-480c-9d84-c4627ebd3c05' => { name: 'Modern foreign languages' },
          '56de0e2f-c5dd-4c40-874a-e50744f8c5a3' => { name: 'Music' },
          '06d573a8-c662-47bc-976a-11fe2c91e264' => { name: 'Philosophy' },
          '57e0d6bd-6b3e-4fbd-8060-5c4b01f23da3' => { name: 'Physical education' },
          '047bf5ad-9d32-437f-8f69-7314829d99bd' => { name: 'Physics' },
          '6968c8ea-254c-4c63-b91c-9d90ac28c683' => { name: 'Psychology' },
          'e63aac7d-5e98-49df-a17e-4c599b16ca7d' => { name: 'Religious education' },
          '2f3681f6-3d05-46a8-969c-ed6f11ad0a8f' => { name: 'Social sciences' },
          schema: SUBJECT_GROUPS_SCHEMA,
        },
      )
    end
  end
end
