module BoardHelper
  def get_total_for_today(issue)
    total_for_today = 0
    issue.custom_field_values.each do |field|
      if field.custom_field.name == settings_today_time_field_name
        if field.value.nil? || field.value.to_f == 0.0
          total_for_today = issue.estimated_hours.to_f - issue.spent_hours.to_f
        else
          total_for_today = field.value.to_f
        end
      end
    end

    if total_for_today < 0
      return 0
    end

    return total_for_today.round(2)
  end

  def settings_today_time_field_name
    (Setting.plugin_daily_workload_management && Setting.plugin_daily_workload_management.include?('field')) ? Setting.plugin_daily_workload_management['field'] : ''
  end

  def settings_today_time_status_name
    (Setting.plugin_daily_workload_management && Setting.plugin_daily_workload_management.include?('status')) ? Setting.plugin_daily_workload_management['status'] : ''
  end

  def get_user_total_today_time
    today_status    = IssueStatus.find_by_name(settings_today_time_status_name)
    total_for_today = 0

    if today_status.nil?
      return total_for_today
    end

    current_user = User.current
    if current_user.nil?
      return total_for_today
    end

    total_for_today = ActiveRecord::Base.connection.execute("
      SELECT
          SUM(custom_values.value) AS total_for_today
      FROM
          issues
              INNER JOIN
          custom_values ON issues.id = custom_values.customized_id
      WHERE
          issues.assigned_to_id = #{current_user.id}
              AND issues.status_id NOT IN (SELECT
                  id
              FROM
                  issue_statuses
              WHERE
                  is_closed = 1)
              AND custom_values.custom_field_id = #{IssueCustomField.find_by_name(settings_today_time_field_name).id};
    ")

    total_for_today.to_a[0][0].to_f.round(2)
  end
end
