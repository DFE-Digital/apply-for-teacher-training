require 'rails_helper'

RSpec.describe PersonalDetailsReviewPresenter do
  describe '#present' do
    it 'includes hashes for the name and date of birth' do
      personal_details_form = build(
        :application_form,
        first_name: 'Max',
        last_name: 'Caulfield',
        date_of_birth: '1995/9/21',
      )

      expect(rows(personal_details_form)).to include(
        row_for(:name, 'Max Caulfield'),
        row_for(:date_of_birth, '21 September 1995'),
      )
    end

    context 'when presenting nationality' do
      it 'includes a hash for a single nationality' do
        personal_details_form = build(
          :application_form,
          first_nationality: 'British',
          second_nationality: nil,
        )

        expect(rows(personal_details_form)).to include(
          row_for(:nationality, 'British'),
        )
      end

      it 'includes a hash for dual nationalities' do
        personal_details_form = build(
          :application_form,
          first_nationality: 'British',
          second_nationality: 'Spanish',
        )

        expect(rows(personal_details_form)).to include(
          row_for(:nationality, 'British and Spanish'),
        )
      end
    end

    # context 'when presenting English as the main language' do
    #   it 'includes a hash with "Yes"' do
    #     personal_details_form = build(
    #       :personal_details_form,
    #       english_main_language: 'yes',
    #       english_language_details: '',
    #       other_language_details: '',
    #     )
    #
    #     expect(rows(personal_details_form)).to include(
    #       row_for(:english_main_language, 'Yes'),
    #     )
    #   end
    #
    #   it 'excludes a hash for English language details if blank' do
    #     personal_details_form = build(
    #       :personal_details_form,
    #       english_main_language: 'yes',
    #       english_language_details: '',
    #       other_language_details: '',
    #     )
    #
    #     expect(rows(personal_details_form)).not_to include(
    #       row_for(:english_main_language_details, ''),
    #     )
    #   end
    #
    #   it 'excludes a hash for other language details if given' do
    #     personal_details_form = build(
    #       :personal_details_form,
    #       english_main_language: 'yes',
    #       english_language_details: '',
    #       other_language_details: 'Broken? Oh man, are you cereal?',
    #     )
    #
    #     expect(rows(personal_details_form)).not_to include(
    #       row_for(:other_language_details, 'Broken? Oh man, are you cereal?'),
    #     )
    #   end
    #
    #   it 'includes a hash for English language details if given' do
    #     personal_details_form = build(
    #       :personal_details_form,
    #       english_main_language: 'yes',
    #       english_language_details: 'Mi nombre es Max.',
    #       other_language_details: '',
    #     )
    #
    #     expect(rows(personal_details_form)).to include(
    #       row_for(:english_main_language_details, 'Mi nombre es Max.'),
    #     )
    #   end
    # end
    #
    # context 'when presenting English not as the main language' do
    #   it 'includes a hash with "No"' do
    #     personal_details_form = build(
    #       :personal_details_form,
    #       english_main_language: 'no',
    #       english_language_details: '',
    #       other_language_details: '',
    #     )
    #
    #     expect(rows(personal_details_form)).to include(
    #       row_for(:english_main_language, 'No'),
    #     )
    #   end
    #
    #   it 'excludes a hash for other language details if blank' do
    #     personal_details_form = build(
    #       :personal_details_form,
    #       english_main_language: 'no',
    #       english_language_details: '',
    #       other_language_details: '',
    #     )
    #
    #     expect(rows(personal_details_form)).not_to include(
    #       row_for(:other_language_details, ''),
    #     )
    #   end
    #
    #   it 'excludes a hash for English language details if given' do
    #     personal_details_form = build(
    #       :personal_details_form,
    #       english_main_language: 'no',
    #       english_language_details: 'Mi nombre es Max.',
    #       other_language_details: '',
    #     )
    #
    #     expect(rows(personal_details_form)).not_to include(
    #       row_for(:english_main_language_details, 'Mi nombre es Max.'),
    #     )
    #   end
    #
    #   it 'includes a hash for other language details if given' do
    #     personal_details_form = build(
    #       :personal_details_form,
    #       english_main_language: 'no',
    #       english_language_details: '',
    #       other_language_details: 'Broken? Oh man, are you cereal?',
    #     )
    #
    #     expect(rows(personal_details_form)).to include(
    #       row_for(:other_language_details, 'Broken? Oh man, are you cereal?'),
    #     )
    #   end
    # end
  end

  def rows(form)
    PersonalDetailsReviewPresenter.new(form).rows
  end

  def row_for(key, value)
    {
      key: t("application_form.personal_details.#{key}.label"),
      value: value,
      action: t("application_form.personal_details.#{key}.change_action"),
      change_path: Rails.application.routes.url_helpers.candidate_interface_personal_details_edit_path,
    }
  end
end
