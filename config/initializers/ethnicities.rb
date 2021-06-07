module EthnicGroup
  ASIAN = 'Asian or Asian British'.freeze
  BLACK = 'Black, African, Black British or Caribbean'.freeze
  MIXED = 'Mixed or multiple ethnic groups'.freeze
  WHITE = 'White'.freeze
  OTHER = 'Another ethnic group'.freeze

  def self.all
    [ASIAN, BLACK, MIXED, WHITE, OTHER]
  end
end

ETHNIC_BACKGROUNDS = {
  EthnicGroup::ASIAN => %w[Bangladeshi Chinese Indian Pakistani],
  EthnicGroup::BLACK => %w[African Caribbean],
  EthnicGroup::MIXED => ['Asian and White', 'Black African and White', 'Black Caribbean and White'],
  EthnicGroup::WHITE => ['British, English, Northern Irish, Scottish, or Welsh', 'Irish', 'Irish Traveller or Gypsy'],
  EthnicGroup::OTHER => %w[Arab],
}.freeze

OTHER_ETHNIC_BACKGROUNDS = {
  EthnicGroup::ASIAN => 'Another Asian background',
  EthnicGroup::BLACK => 'Another Black background',
  EthnicGroup::MIXED => 'Another Mixed background',
  EthnicGroup::WHITE => 'Another White background',
  EthnicGroup::OTHER => 'Another ethnic background',
}.freeze
