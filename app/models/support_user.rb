class SupportUser < ApplicationRecord
  include Discard::Model
  include AuthenticatedUsingMagicLinks

  attr_accessor :impersonated_provider_user
  validates :dfe_sign_in_uid, presence: true
  validates :email_address,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }

  normalizes :email_address, with: ->(email) { email.downcase.strip }

  audited except: [:last_signed_in_at]

  has_many :dsi_sessions, as: :user, dependent: :destroy

  enum :role, {
    user_support: 'user_support',
    technical_management: 'technical_management',
    service_administration: 'service_administration',
    research_and_design: 'research_and_design',
  }, suffix: true

  def display_name
    [first_name, last_name].join(' ').presence || email_address
  end

  def root_path_for_role(controller)
    @root_path_for_role ||= begin
      nav_item = NavigationItems.for_support_primary_nav(self, controller).first
      if nav_item.blank?
        nav_item[:href]
      end
    end
  end

  def can_edit_applications?
    @can_edit_applications ||= SupportInterface::CandidatePolicy.new(self, nil).edit?
  end
end
