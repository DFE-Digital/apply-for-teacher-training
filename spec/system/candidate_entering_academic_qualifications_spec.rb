require 'rails_helper'

describe 'A candidate adding a Degree' do
  context 'who successfully enters their details' do
    before do
      visit '/degrees/new'

      fill_in_degree_details

      click_on t('application_form.save_and_continue')
    end

    it 'sees a summary of those details' do
      expect(page).to have_content('BA')
    end

    context 'and wishes to amend their details' do
      it 'can go back and edit them' do
        visit '/check_your_answers'

        find('#change-degree').click
        expect(page).to have_field('Type of degree', with: 'BA')
      end
    end
  end

  context 'who leaves out a required field' do
    before do
      visit '/contact_details/new'
    end

    it 'sees an error summary' do
      click_on t('application_form.save_and_continue')

      expect(page).to have_content('There is a problem')
    end
  end

private

  def fill_in_degree_details
    details = {
      type: 'BA',
      subject: 'Philosophy',
      institution: 'University of London',
      class: 'first',
      year: 2000
    }

    fill_in t('application_form.degree_details_section.type.label'), with: details[:type]
    fill_in t('application_form.degree_details_section.subject.label'), with: details[:subject]
    fill_in t('application_form.degree_details_section.institution.label'), with: details[:institution]
    fill_in t('application_form.degree_details_section.class.label'), with: details[:class]
    fill_in t('application_form.degree_details_section.year.label'), with: details[:year]
  end
end
