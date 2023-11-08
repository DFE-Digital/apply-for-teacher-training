module Publications
  class DataTableComponentPreview < ViewComponent::Preview
    def default
      render_with_template(template: 'publications/data_table_component/default', locals: { age_title:, age_data:, phase_title:, phase_data: })
    end

  private

    def age_title = 'Age'

    def age_data
      {
        submitted: [
          { title: '18 - 21', this_cycle: rand(100), last_cycle: rand(100) },
          { title: '22 - 30', this_cycle: rand(100), last_cycle: rand(100) },
          { title: '30 - 45', this_cycle: rand(100), last_cycle: rand(100) },
        ],
        with_offers: [
          { title: '18 - 21', this_cycle: rand(100), last_cycle: rand(100) },
          { title: '22 - 30', this_cycle: rand(100), last_cycle: rand(100) },
          { title: '30 - 45', this_cycle: rand(100), last_cycle: rand(100) },
        ],
      }
    end

    def phase_title = 'Phase'

    def phase_data
      {
        submitted: [
          { title: 'Primary', this_cycle: rand(100), last_cycle: rand(100) },
          { title: 'Secondary', this_cycle: rand(100), last_cycle: rand(100) },
        ],
        with_offers: [
          { title: 'Primary', this_cycle: rand(100), last_cycle: rand(100) },
          { title: 'Secondary', this_cycle: rand(100), last_cycle: rand(100) },
        ],
      }
    end
  end
end
