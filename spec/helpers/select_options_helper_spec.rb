require 'rails_helper'

RSpec.describe SelectOptionsHelper, type: :helper do
  describe '#select_nationality_options' do
    it 'returns a structured list of nationalities' do
      _, nationality = NATIONALITIES.sample

      expect(select_nationality_options).to include(
        OpenStruct.new(
          id: '',
          name: t('application_form.personal_details.nationality.default_option'),
        ),
      )
      expect(select_nationality_options).to include(
        OpenStruct.new(
          id: nationality,
          name: nationality,
        ),
      )
    end
  end
end
