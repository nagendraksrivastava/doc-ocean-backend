class AppRelease < ActiveRecord::Base
  validates :app_version, :numeric_version, :app_type, presence: true
  enum app_type: {consumer: 'consumer', expert: 'expert'}

  def self.latest_app_version(app_type)
    AppRelease.where(app_type: app_type).order('numeric_version desc').last.try(:app_version)
  end

  def self.app_version_depreciated?(app_type, app_version)
    AppRelease.where(app_type: app_type, app_version: app_version, depreciated: true).any?
  end
end
