require 'rails_helper'

RSpec.describe SupportInterface::ReasonsForRejectionSearchResultsComponent do
  def render_result(application_choices, search_attribute = :id, search_value = 'qualifications')
    render_inline(described_class.new(search_attribute:,
                                      search_value:,
                                      application_choices:))
  end

  context 'for a top-level reason' do
    let(:application_choice) do
      build(
        :application_choice,
        structured_rejection_reasons: {
          selected_reasons: [
            {
              id: 'qualifications',
              label: 'Qualification',
              selected_reasons: [
                {
                  id: 'unsuitable_degree',
                  label: 'Degree does not meet course requirements',
                  details: {
                    id: 'unsuitable_degree_details',
                    text: 'The statement lack detail and depth',
                  },
                },
                {
                  id: 'no_maths_gcse',
                  label: 'No maths GCSE at minimum grade 4 or C, or equivalent',
                },
              ],
            },
          ],
        },
        application_form_id: 123,
      )
    end

    let(:rendered_result) { render_result([application_choice]) }

    it 'renders a link to the application form' do
      expect(rendered_result.css("a[href='/support/applications/123']")).to be_present
    end

    it 'renders top-level reasons' do
      expect(rendered_result.text).to include('Qualifications')
      expect(rendered_result.text).to include('The statement lack detail and depth')
    end

    it 'renders sub-reasons' do
      expect(rendered_result.text).to include('No maths GCSE at minimum grade 4 or C, or equivalent')
    end

    it 'highlights the search term' do
      expect(rendered_result.css('mark').text).to eq 'Qualifications'
    end
  end

  context 'error handling' do
    it 'handles an invalid top-level attribute param' do
      expect { render_result([], :velocity_of_application_y_n, 'Yes') }.not_to raise_error
    end

    it 'handles an invalid sub-reason value param' do
      expect { render_result([], :qualifications, 'no_pilots_licence') }.not_to raise_error
    end
  end
end
