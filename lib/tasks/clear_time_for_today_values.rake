desc "Clear 'time for today' issue field values"
task :clear_time_for_today_values => :environment do
  custom_field = CustomField.find_by name: 'Total for today'
  CustomValue.where(custom_field: custom_field).destroy_all
end
