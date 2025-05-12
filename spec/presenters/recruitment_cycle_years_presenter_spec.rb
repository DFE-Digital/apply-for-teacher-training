require 'rails_helper'

RSpec.describe RecruitmentCycleYearsPresenter do
  it 'returns an empty hash when start year is before 2020' do
    expect(described_class.call(start_year: 2019)).to eq({})
  end

  it 'returns an empty has if end year is before the start year' do
    expect(described_class.call(start_year: 2025, end_year: 2024)).to eq({})
  end

  it 'returns the cycle strings up to one year from current_year', time: mid_cycle(2023) do
    expect(described_class.call).to eq(
      {
        '2023' => '2022 to 2023',
        '2022' => '2021 to 2022',
        '2021' => '2020 to 2021',
        '2020' => '2019 to 2020',
      },
    )
  end

  it 'returns cycle strings with an indicator about which range is "current"', time: mid_cycle(2023) do
    expect(described_class.call(with_current_indicator: true)).to eq(
      {
        '2023' => '2022 to 2023 - current',
        '2022' => '2021 to 2022',
        '2021' => '2020 to 2021',
        '2020' => '2019 to 2020',
      },
    )
  end

  it 'returns cycle strings for years in a given range' do
    result = described_class.call(start_year: 2021, end_year: 2026)

    expect(result).to eq(
      {
        '2026' => '2025 to 2026',
        '2025' => '2024 to 2025',
        '2024' => '2023 to 2024',
        '2023' => '2022 to 2023',
        '2022' => '2021 to 2022',
        '2021' => '2020 to 2021',
      },
    )
  end
end
