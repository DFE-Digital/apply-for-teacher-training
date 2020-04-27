require 'rails_helper'

RSpec.describe EthnicBackgroundHelper, type: :helper do
  describe '#ethnic_backgrounds' do
    let(:group) { EthnicBackgroundHelper::ETHNIC_GROUPS.sample }

    it 'return a stuctured list of all listed ethnic backgrounds' do
      expected_background = EthnicBackgroundHelper::ETHNIC_BACKGROUNDS[group].sample

      expect(ethnic_backgrounds(group)).to include(
        OpenStruct.new(
          label: expected_background,
          textfield_label: nil,
        ),
      )
    end

    it 'includes a label for the contextual other ethnic background descreption textfield' do
      expected_other_background = EthnicBackgroundHelper::OTHER_ETHNIC_BACKGROUNDS[group]

      expect(ethnic_backgrounds(group)).to include(
        OpenStruct.new(
          label: expected_other_background.first,
          textfield_label: expected_other_background.second,
        ),
      )
    end
  end

  describe '#ethnic_background_title' do
    it 'returns a title for a given ethnic group' do
      group = 'Asian or Asian British'
      expect(ethnic_background_title(group)).to include('Which of the following best describes your Asian or Asian British background?')
    end

    it 'returns the correct title for "Another ethnic group"' do
      group = 'Another ethnic group'
      expect(ethnic_background_title(group)).to include('Which of the following best describes your ethnicity?')
    end
  end

  describe '#all_combinations' do
    it 'returns an array' do
      expect(all_combinations).to be_a(Array)
    end

    it 'has an entry for each combination of group and background' do
      result = all_combinations
      EthnicBackgroundHelper::ETHNIC_GROUPS.each do |group|
        sorted_backgrounds = result.select { |e| e.first == group }.map(&:last).sort
        expect(sorted_backgrounds).to eq(EthnicBackgroundHelper::ETHNIC_BACKGROUNDS[group].sort)
      end
    end
  end
end
