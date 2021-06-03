module EthnicBackgroundHelper
  ETHNIC_BACKGROUND_TEXTFIELD_LABELS = {
    EthnicGroup::ASIAN => 'Your Asian background (optional)',
    EthnicGroup::BLACK => 'Your Black background (optional)',
    EthnicGroup::MIXED => 'Your Mixed background (optional)',
    EthnicGroup::WHITE => 'Your White background (optional)',
    EthnicGroup::OTHER => 'Describe your ethnic background (optional)',
  }.freeze

  def ethnic_backgrounds(group)
    ethnic_backgrounds = ETHNIC_BACKGROUNDS[group].map do |background|
      OpenStruct.new(
        label: background,
        textfield_label: nil,
      )
    end

    button_label = OTHER_ETHNIC_BACKGROUNDS[group]
    textfield_label = ETHNIC_BACKGROUND_TEXTFIELD_LABELS[group]

    ethnic_backgrounds << OpenStruct.new(
      label: button_label,
      textfield_label: textfield_label,
    )
  end

  def ethnic_background_title(group)
    return t('equality_and_diversity.ethnic_background.title_other') if group == 'Another ethnic group'

    t('equality_and_diversity.ethnic_background.title', group: group)
  end

  # return every possible combination of group + background
  # used in the factory for generating sensible combinations in test data
  def all_combinations
    combos = []
    EthnicGroup.all.each do |group|
      ETHNIC_BACKGROUNDS[group].each do |bg|
        combos << [group, bg]
      end
    end
    combos
  end
end
