module CandidateInterface
  class EqualityAndDiversity::DisabilitiesForm
    include ActiveModel::Model

    DISABILITIES = [
      %w[blind Blind],
      %w[deaf Deaf],
      ['learning', 'Learning difficulty'],
      ['long_standing', 'Long-standing illness'],
      ['mental', 'Mental health condition'],
      ['physical', 'Physical disability or mobility issue'],
      ['social', 'Social or communication impairment'],
    ].freeze

    attr_accessor :disabilities, :other_disability

    validates :disabilities, presence: true

    def self.build_from_application(application_form)
      return new(disabilities: nil) if application_form.equality_and_diversity.nil?

      list_of_disabilities = DISABILITIES.map { |_, disability| disability } << 'Other'
      listed, other = application_form.equality_and_diversity['disabilities'].partition { |d| list_of_disabilities.include?(d) }

      if other.any?
        listed << 'Other'

        new(disabilities: listed, other_disability: other.first)
      else
        new(disabilities: listed)
      end
    end

    def save(application_form)
      return false unless valid?

      if disabilities.include?('Other') && other_disability.present?
        disabilities.delete('Other'); disabilities << other_disability
      end

      if application_form.equality_and_diversity.nil?
        application_form.update(equality_and_diversity: { 'disabilities' => disabilities })
      else
        application_form.equality_and_diversity['disabilities'] = disabilities
        application_form.save
      end
    end
  end
end
