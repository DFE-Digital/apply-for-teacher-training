require 'rails_helper'

RSpec.describe PaginatorComponent do
  def rendered_component(current_page: 1, total_count: 12)
    page_size = 25
    relation = ApplicationChoice.all.page(1)

    # Using an `object_double` here because I want to stub the
    # ActiveRecord::Relation passed into the component and I can't use
    # `instance_double(ActiveRecord::Relation...)` as it lacks the
    # extra methods that Kaminari mixes in (e.g. `total_count`)
    scope = object_double(
      relation,
      total_count: total_count,
      limit_value: page_size,
      current_page: current_page,
      total_pages: (total_count.to_f / page_size).ceil,
    )
    component = described_class.new(scope: scope)
    allow(component).to receive(:paginate).and_return('paginator')
    render_inline(component)
  end

  context 'pagination behaviour' do
    context 'when there is only one page' do
      it 'renders nothing' do
        expect(rendered_component.text).to eq ''
      end
    end

    context 'when we are on the first of two pages' do
      it 'renders correct summary message' do
        expect(rendered_component(current_page: 1, total_count: 29).text).to include 'Showing 1 to 25 of 29'
      end
    end

    context 'when we are on the second of two pages' do
      it 'renders correct summary message' do
        expect(rendered_component(current_page: 2, total_count: 29).text).to include 'Showing 26 to 29 of 29'
      end
    end

    context 'when we are on the second of three pages' do
      it 'renders correct summary message' do
        expect(rendered_component(current_page: 2, total_count: 59).text).to include 'Showing 26 to 50 of 59'
      end
    end
  end
end
