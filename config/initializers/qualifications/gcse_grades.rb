SINGLE_GCSE_GRADES = %w[9 8 7 6 5 4 3 2 1 A* A B C C* D E F G U].freeze
DOUBLE_GCSE_GRADES = %w[
  9-8
  9-9
  8-8
  8-7
  7-7
  7-6
  6-6
  6-5
  5-5
  5-4
  4-4
  4-3
  3-3
  3-2
  2-2
  2-1
  1-1
  A*A
  A*A*
  AA
  AB
  AC
  BB
  BC
  CC
  CD
  DD
  DE
  EE
  EF
  FF
  FG
  GG
  U
].freeze
ALL_GCSE_GRADES = (SINGLE_GCSE_GRADES + DOUBLE_GCSE_GRADES).uniq
