require 'rails_helper'

RSpec.describe SupportInterface::PermissionsListReviewComponent do
  let(:tick_svg_path_shape) { 'M100 200a100 100 0 1 1 0-200 100 100 0 0 1 0 200zm-60-85l40 40 80-80-20-20-60 60-20-20-20 20z' }
  let(:cross_svg_path_shape) { 'M100 0a100 100 0 110 200 100 100 0 010-200zm30 50l-30 30-30-30-20 20 30 30-30 30 20 20 30-30 30 30 20-20-30-30 30-30-20-20z' }

  context 'Manage organisational permissions' do
    it 'displays permission has been assigned' do
      permissions = { 'manage_organisations' => true }

      result = render_inline(described_class.new(permissions))

      expect(result.css('li').text).to include('Manage organisational permissions')
      expect(result.css('path')[0].attribute('d').value).to eq(tick_svg_path_shape)
    end

    it 'does not display that permission has been assigned' do
      permissions = {}

      result = render_inline(described_class.new(permissions))

      expect(result.css('li').text).to include('Manage users')
      expect(result.css('path')[0].attribute('d').value).to eq(cross_svg_path_shape)
    end
  end

  context 'Manage other users' do
    it 'displays permission has been assigned' do
      permissions = { 'manage_users' => true }

      result = render_inline(described_class.new(permissions))

      expect(result.css('li').text).to include('Manage users')
      expect(result.css('path')[1].attribute('d').value).to eq(tick_svg_path_shape)
    end

    it 'does not display that permission has been assigned' do
      permissions = {}

      result = render_inline(described_class.new(permissions))

      expect(result.css('li').text).to include('Manage users')
      expect(result.css('path')[1].attribute('d').value).to eq(cross_svg_path_shape)
    end
  end

  context 'Make decisions' do
    it 'displays permission has been assigned' do
      permissions = { 'make_decisions' => true }

      result = render_inline(described_class.new(permissions))

      expect(result.css('li').text).to include('Make decisions')
      expect(result.css('path')[2].attribute('d').value).to eq(tick_svg_path_shape)
    end

    it 'does not display that permission has been assigned' do
      permissions = {}

      result = render_inline(described_class.new(permissions))

      expect(result.css('li').text).to include('Make decisions')
      expect(result.css('path')[2].attribute('d').value).to eq(cross_svg_path_shape)
    end
  end

  context 'Access safeguarding information' do
    it 'displays permission has been assigned' do
      permissions = { 'view_safeguarding_information' => true }

      result = render_inline(described_class.new(permissions))

      expect(result.css('li').text).to include('Access safeguarding information')
      expect(result.css('path')[3].attribute('d').value).to eq(tick_svg_path_shape)
    end

    it 'does not display that permission has been assigned' do
      permissions = {}

      result = render_inline(described_class.new(permissions))

      expect(result.css('li').text).to include('Access safeguarding information')
      expect(result.css('path')[3].attribute('d').value).to eq(cross_svg_path_shape)
    end
  end

  context 'Access diversity information' do
    it 'displays permission has been assigned' do
      permissions = { 'view_diversity_information' => true }

      result = render_inline(described_class.new(permissions))

      expect(result.css('li').text).to include('Access diversity information')
      expect(result.css('path')[4].attribute('d').value).to eq(tick_svg_path_shape)
    end

    it 'does not display that permission has been assigned' do
      permissions = {}

      result = render_inline(described_class.new(permissions))

      expect(result.css('li').text).to include('Access diversity information')
      expect(result.css('path')[4].attribute('d').value).to eq(cross_svg_path_shape)
    end
  end
end
