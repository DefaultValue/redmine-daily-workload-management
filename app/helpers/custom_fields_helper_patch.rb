require_dependency '../../../plugins/daily_workload_management/app/helpers/board_helper'

module CustomFieldsHelperPatch

  def self.included(base)
    base.send(:include, CustomMethods)

    base.class_eval do
      alias_method_chain :custom_field_tag, :time_for_today
    end
  end

  module CustomMethods

    include BoardHelper

    # Return custom field html tag corresponding to its format with taking into consideration 'time for today' field
    def custom_field_tag_with_time_for_today(prefix, custom_value)

      # BoardHelper.settings_today_time_field_name
      if custom_value.custom_field.name == settings_today_time_field_name
        spent_hours        = custom_value.customized.spent_hours
        estimated_hours    = custom_value.customized.estimated_hours
        custom_value.value = if custom_value.value.nil? || custom_value.value.empty? then
                               estimated_hours.nil? ? 0 : estimated_hours - spent_hours
                             else
                               custom_value.value
                             end
      end
      custom_value.custom_field.format.edit_tag self,
        custom_field_tag_id(prefix, custom_value.custom_field),
        custom_field_tag_name(prefix, custom_value.custom_field),
        custom_value,
        :class => "#{custom_value.custom_field.field_format}_cf"
    end
  end
end

CustomFieldsHelper.send(:include, CustomFieldsHelperPatch)
