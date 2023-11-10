require 'rails_helper'

RSpec.describe 'Routes for MonthlyStatistics', type: :routing do
  describe 'when monthly_statistics_redirected is disabled' do
    before { FeatureFlag.deactivate(:monthly_statistics_redirected) }

    it 'routes /publications/monthly-statistics/august' do
      expect(get('/publications/monthly-statistics')).to route_to('publications/monthly_statistics#show')
    end
  end

  describe 'when monthly_statistics_redirected is enabled' do
    before { FeatureFlag.activate(:monthly_statistics_redirected) }

    it 'routes /publications/monthly-statistics/august' do
      expect(get('/publications/monthly-statistics')).to route_to({ 'controller' => 'errors', 'action' => 'not_found', 'path' => 'publications/monthly-statistics' })
    end
  end
end
