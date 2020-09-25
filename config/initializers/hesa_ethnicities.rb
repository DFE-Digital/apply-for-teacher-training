# https://www.hesa.ac.uk/collection/c19053/e/ethnic
HESA_ETHNICITIES_2019_2020 = [
  [10, 'White'],
  [15, 'Gypsy or Traveller'],
  [21, 'Black or Black British - Caribbean'],
  [22, 'Black or Black British - African'],
  [29, 'Other Black background'],
  [31, 'Asian or Asian British - Indian'],
  [32, 'Asian or Asian British - Pakistani'],
  [33, 'Asian or Asian British - Bangladeshi'],
  [34, 'Chinese'],
  [39, 'Other Asian background'],
  [41, 'Mixed - White and Black Caribbean'],
  [42, 'Mixed - White and Black African'],
  [43, 'Mixed - White and Asian'],
  [49, 'Other Mixed background'],
  [50, 'Arab'],
  [80, 'Other Ethnic background'],
  [90, 'Not known'],
  [98, 'Information refused'],
].freeze

# Two codes have been dropped in 2020/21
# https://www.hesa.ac.uk/collection/c20053/e/ethnic
HESA_ETHNICITIES_2020_2021 = HESA_ETHNICITIES_2019_2020
                               .reject { |ethnicity| [90, 98].include?(ethnicity.first) }
