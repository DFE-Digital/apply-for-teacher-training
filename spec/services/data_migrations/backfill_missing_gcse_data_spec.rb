require 'rails_helper'

RSpec.describe DataMigrations::BackfillMissingGcseData do
  it 'sets the desired attrs and sets updated sections to incomplete for gcses with missing explanations' do
    application_form_in_the_2021_cycle = create(:completed_application_form)
    application_form_in_2022_cycle = create(:completed_application_form, recruitment_cycle_year: 2022)

    maths_gcse_with_explanation = create(
      :gcse_qualification,
      application_form: application_form_in_the_2021_cycle,
      subject: 'maths', grade: 'D',
      missing_explanation: 'I hate maths'
    )

    english_gcse_with_explanation = create(
      :gcse_qualification,
      application_form: application_form_in_2022_cycle,
      subject: 'english',
      grade: 'E',
      missing_explanation: 'I loathe English',
    )

    science_gcse_without_explanation = create(
      :gcse_qualification,
      application_form: application_form_in_2022_cycle,
      subject: 'science',
      grade: 'A',
      missing_explanation: nil,
    )

    described_class.new.change

    expect(maths_gcse_with_explanation.reload.currently_completing_qualification).to eq nil
    expect(maths_gcse_with_explanation.not_completed_explanation).to eq nil
    expect(maths_gcse_with_explanation.missing_explanation).to eq 'I hate maths'
    expect(application_form_in_the_2021_cycle.reload.maths_gcse_completed).to eq true

    expect(english_gcse_with_explanation.reload.currently_completing_qualification).to eq true
    expect(english_gcse_with_explanation.not_completed_explanation).to eq 'I loathe English'
    expect(english_gcse_with_explanation.missing_explanation).to eq nil
    expect(application_form_in_2022_cycle.reload.english_gcse_completed).to eq false

    expect(science_gcse_without_explanation.reload.currently_completing_qualification).to eq nil
    expect(science_gcse_without_explanation.not_completed_explanation).to eq nil
    expect(science_gcse_without_explanation.missing_explanation).to eq nil
    expect(application_form_in_2022_cycle.reload.science_gcse_completed).to eq true
  end
end
