desc "Clear 'time for today' issue field values"
task :clear_time_for_today_values => :environment do
  include BoardHelper

  custom_field = CustomField.find_by name: BoardHelper::settings_today_time_field_name
  CustomValue.where(custom_field: custom_field).destroy_all
end
