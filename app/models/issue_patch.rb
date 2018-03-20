module IssuePatch

  include BoardHelper

  def self.included(base)
    base.send(:include, ExtraMethods)

    base.class_eval do
      alias_method_chain :validate_issue, :total_for_today
    end
  end

  module ExtraMethods
    def validate_issue_with_total_for_today
      if due_date && start_date && (start_date_changed? || due_date_changed?) && due_date < start_date
        errors.add :due_date, :greater_than_start_date
      end

      if start_date && start_date_changed? && soonest_start && start_date < soonest_start
        errors.add :start_date, :earlier_than_minimum_start_date, :date => format_date(soonest_start)
      end

      if fixed_version
        if !assignable_versions.include?(fixed_version)
          errors.add :fixed_version_id, :inclusion
        elsif reopening? && fixed_version.closed?
          errors.add :base, I18n.t(:error_can_not_reopen_issue_on_closed_version)
        end
      end

      # Checks that the issue can not be added/moved to a disabled tracker
      if project && (tracker_id_changed? || project_id_changed?)
        if tracker && !project.trackers.include?(tracker)
          errors.add :tracker_id, :inclusion
        end
      end

      if assigned_to_id_changed? && assigned_to_id.present?
        unless assignable_users.include?(assigned_to)
          errors.add :assigned_to_id, :invalid
        end
      end

      # Checks parent issue assignment
      if @invalid_parent_issue_id.present?
        errors.add :parent_issue_id, :invalid
      elsif @parent_issue
        if !valid_parent_project?(@parent_issue)
          errors.add :parent_issue_id, :invalid
        elsif (@parent_issue != parent) && (
        self.would_reschedule?(@parent_issue) ||
            @parent_issue.self_and_ancestors.any? {|a| a.relations_from.any? {|r| r.relation_type == IssueRelation::TYPE_PRECEDES && r.issue_to.would_reschedule?(self)}}
        )
          errors.add :parent_issue_id, :invalid
        elsif !closed? && @parent_issue.closed?
          # cannot attach an open issue to a closed parent
          errors.add :base, :open_issue_with_closed_parent
        elsif !new_record?
          # moving an existing issue
          if move_possible?(@parent_issue)
            # move accepted
          else
            errors.add :parent_issue_id, :invalid
          end
        end
      end

      if BoardHelper.getHandleBoardUpdate
        BoardHelper.setHandleBoardUpdate(false)
        self.validate_total_for_today
      end

    end

    # Validates total for today field
    def validate_total_for_today
      issue_status      = IssueStatus.find(self.status_id)
      issue_status_name = issue_status.name

      self.custom_field_values.each do |custom_field_value|
        custom_field_name = custom_field_value.custom_field.name
        if custom_field_name == settings_today_time_field_name && issue_status_name == settings_today_time_status_name
          estimated_hours    = self.estimated_hours.to_f
          spent_hours        = self.spent_hours
          left_hours         = (estimated_hours - spent_hours).round(2)
          custom_field_value = custom_field_value.value.to_f
          if estimated_hours != 0 && left_hours < custom_field_value
            errors.add custom_field_name, l(:notification_should_be_greater, :left_hours => left_hours.to_s)
          end
        end
      end
    end
  end
end

Issue.send(:include, IssuePatch)
