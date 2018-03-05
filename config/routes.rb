get 'board', to: 'board#index', :as => 'workload_management_board'

post 'board/issue/:id/will-do-today', :to => 'board#will_do_today'
post 'board/issue/:id/update-time-for-today', :to => 'board#update_time_for_today'
