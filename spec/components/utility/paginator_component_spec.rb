require 'rails_helper'

RSpec.describe PaginatorComponent do
  def rendered_component(current_page: 1, total_count: 12)
    page_size = 25
    relation = ApplicationChoice.all.page(1)

    # Using an `object_double` here because I want to stub the
    # ActiveRecord::Relation passed into the component and I cannot use
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

  describe 'pagination behaviour' do
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

  describe '#paginate_configuration' do
    def paginate_configuration(total_pages:, current_page: 1)
      # rubocop:disable RSpec/VerifiedDoubles
      scope = double(
        total_count: total_pages * 25,
        limit_value: 25,
        current_page: current_page,
        total_pages: total_pages,
      )
      # rubocop:enable RSpec/VerifiedDoubles

      described_class.new(scope: scope).paginate_configuration
    end

    context 'when there are KAMINARI_LINKS_LIMIT or fewer pages (e.g. 5)' do
      def verify_default_paginate_configuration(config)
        expect(config).to eq(
          {
            window: 4,
            left: 0,
            right: 0,
          },
        )
      end

      it 'displays links for every page on every page' do
        (1..5).each do |page|
          config = paginate_configuration(total_pages: 5, current_page: page)
          verify_default_paginate_configuration(config)
        end
      end
    end

    context 'when there are more than KAMINARI_LINKS_LIMIT pages (e.g. 9)' do
      describe 'on page 1' do
        let(:result) { paginate_configuration(total_pages: 9, current_page: 1) }

        it 'displays 4 links on the left' do
          expect(result[:left]).to eq(4)
        end

        it 'displays 1 link on the right' do
          expect(result[:right]).to eq(1)
        end

        it 'no links in the middle' do
          expect(result[:window]).to eq(0)
        end
      end

      describe 'on page 4' do
        let(:result) { paginate_configuration(total_pages: 9, current_page: 4) }

        it 'displays 1 link on the left' do
          expect(result[:left]).to eq(1)
        end

        it 'displays 1 link on the right' do
          expect(result[:right]).to eq(1)
        end

        it 'displays 3 links in the middle' do
          expect(result[:window]).to eq(1)
        end
      end

      describe 'on page 6' do
        let(:result) { paginate_configuration(total_pages: 9, current_page: 6) }

        it 'displays 1 link on the left' do
          expect(result[:left]).to eq(1)
        end

        it 'displays 1 link on the right' do
          expect(result[:right]).to eq(1)
        end

        it 'displays 3 links in the middle' do
          expect(result[:window]).to eq(1)
        end
      end

      describe 'on page 9' do
        let(:result) { paginate_configuration(total_pages: 9, current_page: 9) }

        it 'displays 1 link on the left' do
          expect(result[:left]).to eq(1)
        end

        it 'displays 4 links on the right' do
          expect(result[:right]).to eq(4)
        end

        it 'displays no links in the middle' do
          expect(result[:window]).to eq(0)
        end
      end
    end
  end
end
