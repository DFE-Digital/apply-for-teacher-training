require 'rails_helper'

describe ApplicationHelper do
  describe '#page_title' do
    context 'given a page is not defined in the translation file' do
      it 'returns the application title' do
        page_title = helper.page_title(:meow)

        expect(page_title).to eq(t('page_titles.application'))
      end
    end

    context 'given a page is defined in the translation file' do
      it 'returns the page name with the application title' do
        page_title = helper.page_title(:personal_details)

        expect(page_title).to eq("#{t('page_titles.personal_details')} - #{t('page_titles.application')}")
      end
    end
  end

  describe '#page_heading' do
    context 'when action is supported' do
      let(:action) { :new }

      it 'returns the correct heading' do
        heading = helper.page_heading(:edit, 'degree')

        expect(heading).to eq 'Edit degree'
      end
    end

    context 'when action is NOT supported' do
      let(:action) { :non_existent_action }

      it 'raised Action not supported error' do
        expect {
          helper.page_heading(:action, 'degree')
        }.to raise_error(KeyError)
      end
    end
  end
end
