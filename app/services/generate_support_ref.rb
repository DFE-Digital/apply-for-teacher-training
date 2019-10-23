class GenerateSupportRef
  NUMBER_OF_LETTERS = 2
  NUMBER_OF_DIGITS = 4

  UNCLEAR_LETTERS = %w[I L O].freeze
  UNCLEAR_DIGIT = [0, 1].freeze

  def self.call
    letters = ('A'..'Z').to_a - UNCLEAR_LETTERS
    digits = ('1'..'9').to_a - UNCLEAR_DIGIT

    random_letters = (1..NUMBER_OF_LETTERS).map { letters.sample }
    random_digits = (1..NUMBER_OF_DIGITS).map { digits.sample }

    (random_letters + random_digits).join
  end
end
