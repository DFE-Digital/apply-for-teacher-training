module EthnicGroup
  ASIAN = 'Asian or Asian British'.freeze
  BLACK = 'Black, African, Caribbean or Black British'.freeze
  MIXED = 'Mixed or multiple ethnic groups'.freeze
  WHITE = 'White'.freeze
  OTHER = 'Another ethnic group'.freeze

  def self.all
    [ASIAN, BLACK, MIXED, WHITE, OTHER]
  end
end

ETHNIC_BACKGROUNDS = {
  EthnicGroup::ASIAN => %w[Indian Pakistani Bangladeshi Chinese],
  EthnicGroup::BLACK => %w[African Caribbean],
  EthnicGroup::MIXED => ['White and Black Caribbean', 'White and Black African', 'White and Asian'],
  EthnicGroup::WHITE => ['English, Welsh, Scottish, Northern Irish or British', 'Irish', 'Gypsy or Irish Traveller', 'Roma'],
  EthnicGroup::OTHER => %w[Arab],
}.freeze

OTHER_ETHNIC_BACKGROUNDS = {
  EthnicGroup::ASIAN => 'Any other Asian background',
  EthnicGroup::BLACK => 'Any other Black, African or Caribbean background',
  EthnicGroup::MIXED => 'Any other mixed or multiple ethnic background',
  EthnicGroup::WHITE => 'Any other White background',
  EthnicGroup::OTHER => 'Any other ethnic group',
}.freeze
