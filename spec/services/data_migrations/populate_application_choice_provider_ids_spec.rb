require 'rails_helper'

RSpec.describe DataMigrations::PopulateApplicationChoiceProviderIds do
  let(:with_accredited_provider_a) do
    create(:course_option, course: create(:course, :with_accredited_provider))
  end

  let(:with_accredited_provider_b) do
    create(:course_option, course: create(:course, :with_accredited_provider))
  end

  def expected_provider_ids(application_choice)
    [
      application_choice.provider&.id,
      application_choice.accredited_provider&.id,
      application_choice.current_provider&.id,
      application_choice.current_accredited_provider&.id,
    ].compact.uniq
  end

  it 'adds all relevant provider ids to provider_ids array' do
    application_choices = [
      create(:application_choice),
      create(:application_choice, course_option: with_accredited_provider_a),
      create(:application_choice),
      create(:application_choice, course_option: with_accredited_provider_a),
    ]
    application_choices[2].update(current_course_option: with_accredited_provider_b)
    application_choices[3].update(current_course_option: with_accredited_provider_b)

    described_class.new.change

    expect(application_choices[3].reload.provider_ids.length).to eq(4)
    expected_arrays = application_choices.map { |a| expected_provider_ids(a) }
    expect(ApplicationChoice.all.map(&:provider_ids)).to eq(expected_arrays)
  end
end
