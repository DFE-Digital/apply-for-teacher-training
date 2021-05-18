module EthnicBackgroundHelper
  ETHNIC_GROUPS = [
    'Asian or Asian British',
    'Black, African, Black British or Caribbean',
    'Mixed or multiple ethnic groups',
    'White',
    'Another ethnic group',
  ].freeze

  ETHNIC_BACKGROUNDS = {
    'Asian or Asian British' => %w[Bangladeshi Chinese Indian Pakistani],
    'Black, African, Black British or Caribbean' => %w[African Caribbean],
    'Mixed or multiple ethnic groups' => ['Asian and White', 'Black African and White', 'Black Caribbean and White'],
    'White' => ['British, English, Northern Irish, Scottish, or Welsh', 'Irish', 'Irish Traveller or Gypsy'],
    'Another ethnic group' => %w[Arab],
  }.freeze

  OTHER_ETHNIC_BACKGROUNDS = {
    'Asian or Asian British' => ['Another Asian background', 'Your Asian background (optional)'],
    'Black, African, Black British or Caribbean' => ['Another Black background', 'Your Black background (optional)'],
    'Mixed or multiple ethnic groups' => ['Another Mixed background', 'Your Mixed background (optional)'],
    'White' => ['Another White background', 'Your White background (optional)'],
    'Another ethnic group' => ['Another ethnic background', 'Describe your ethnic background (optional)'],
  }.freeze

  def ethnic_backgrounds(group)
    ethnic_backgrounds = ETHNIC_BACKGROUNDS[group].map do |background|
      OpenStruct.new(
        label: background,
        textfield_label: nil,
      )
    end

    button_label, textfield_label = OTHER_ETHNIC_BACKGROUNDS[group]

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
    ETHNIC_GROUPS.each do |group|
      ETHNIC_BACKGROUNDS[group].each do |bg|
        combos << [group, bg]
      end
    end
    combos
  end
end
