require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe '#page_title' do
    context 'given a page is not defined in the translation file' do
      it 'returns the application title' do
        page_title = helper.page_title(:meow)

        expect(page_title).to eq(t('page_titles.application'))
      end
    end

    context 'given a page is defined in the translation file' do
      it 'returns the page name with the application title' do
        page_title = helper.page_title(:application_form)

        expect(page_title).to eq("#{t('page_titles.application_form')} - #{t('page_titles.application')}")
      end
    end
  end
end
