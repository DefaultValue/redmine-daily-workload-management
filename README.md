# Daily workload management Redmine plugin

Plugin provides functionality for managing daily workload.

## Installation

1. Clone this plugin to your Redmine plugins directory:

```bash
user@user:/path/to/redmine/plugins$ git clone git@gitlab.allbugs.info:viktorn/daily-workload-management.git daily_workload_management
```

2. Restart Redmine to check plugin availability and configure its options.

3. Create custom issue field for 'time for today' (Administration > Custom fields > New custom field > Issues) 

4. Create issue status which will be used as 'today' status ( Administration > Issue statuses > New status ). 
Go to Workflow page (Administration > Workflow) and set usage of created 'today' status
                                                                                               
5. Go to plugin configuration page (Administration > Plugins > Daily Workload Management plugin > Configure) and set required options: 

- choose custom issue field which will be used as 'time for today' field (field created on step 3)
- choose issue status for which 'time for today' field is required.

6. Set up cron task for clearing 'Time for today' field value before business day starts (for instance: at 04:11 AM):
```
11    4    *    *    *    path/to/redmine/bin/rake clear_time_for_today_values
``` 

## Usage

1. Use 'time for today' issue field for setting planned issue time for current day.

2. Use 'Workload Management' page for managing 'time for today' and/or taking issue to work in current day.

3. Define user groups permissions for getting access to 'Workload Management' page (Administration > Roles and permissions > Permissions report > View board).
As these permissions are defined in the context of projects - user should be a member of the project (Administration > Projects).
