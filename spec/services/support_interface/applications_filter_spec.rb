require 'rails_helper'

RSpec.describe SupportInterface::ApplicationsFilter do
  describe '#filter_records' do
    it 'allows searching by a string' do
      application_form_in = create(:application_form, first_name: 'Foo', last_name: 'Bar')
      create(:application_form, first_name: 'Not', last_name: 'Bar')

      expect(results_for(q: 'foo')).to match_array([application_form_in])
    end

    it 'allows searching by a partial matching string' do
      application_form_in = create(:application_form, first_name: 'Foo Baz', last_name: 'Bar')
      create(:application_form, first_name: 'Not', last_name: 'Bar')

      expect(results_for(q: 'Foo Bar')).to match_array([application_form_in])
    end

    it 'allows searching by a candidate email' do
      application_form_in = create(:application_form, candidate: create(:candidate, email_address: 'foo@example.com'))
      create(:application_form)

      expect(results_for(q: 'foo@example.com')).to match_array([application_form_in])
    end
  end

  def results_for(params)
    SupportInterface::ApplicationsFilter
      .new(params: params)
      .filter_records(ApplicationForm)
  end
end
