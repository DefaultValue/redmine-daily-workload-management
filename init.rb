require_dependency '../../plugins/daily_workload_management/app/helpers/custom_fields_helper_patch'
require_dependency '../../plugins/daily_workload_management/app/helpers/board_helper'
require_dependency '../../plugins/daily_workload_management/app/models/issue_patch'

Redmine::Plugin.register :daily_workload_management do
  name 'Daily Workload Management plugin'
  author 'Default Value'
  description 'Plugin provides functionality for managing daily workload'
  version '1.0'
  author_url 'http://default-value.com/'

  menu :top_menu, :board, { :controller => 'board', :action => 'index' }, :caption => :top_menu_workload_management

  settings \
    :partial => 'settings/required_statuses_settings'

  permission :view_board, :board => :index

end

ActionDispatch::Reloader.to_prepare do
  SettingsHelper.send :include, WorkloadManagementSettingsHelper
end
