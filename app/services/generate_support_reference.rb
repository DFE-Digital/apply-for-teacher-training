class GenerateSupportReference
  NUMBER_OF_LETTERS = 2
  NUMBER_OF_DIGITS = 4

  UNCLEAR_LETTERS = %w[I L O].freeze
  UNCLEAR_DIGIT = %w[0 1].freeze

  READABLE_LETTERS = ('A'..'Z').to_a - UNCLEAR_LETTERS
  READABLE_DIGITS = ('1'..'9').to_a - UNCLEAR_DIGIT

  def self.call
    random_letters = (1..NUMBER_OF_LETTERS).map { READABLE_LETTERS.sample }
    random_digits = (1..NUMBER_OF_DIGITS).map { READABLE_DIGITS.sample }

    (random_letters + random_digits).join
  end
end
