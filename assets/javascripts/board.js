(function () {
    "use strict";

    (function ($) {

        /** --------- Edit time for today --------- */
        $(".time_for_today").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();

            $(".workload-management-flash-notice").hide();

            $(this).find(".time_for_today_input").show().focus();
            $(this).find(".time_for_today_value").hide();
        });

        var $timeForTodayInput = $(".time_for_today_input");
        $timeForTodayInput.on( "focusout", function (e) {
            e.preventDefault();
            e.stopPropagation();

            $(".workload-management-flash-notice").hide();
            $(".time_for_today_input").hide();
            $(".time_for_today_value").show();
        });

        $timeForTodayInput.on( "keydown", function (e) {
            if (e.which === 13 || e.keyCode === 13) {
                var $this        = $(this);
                var inputValue   = $this.val();
                updateTimeForToday.apply(this, [$this.attr("data-issue-id"), inputValue]);

                $(this).blur();
            }
        });

        /** --------- Mark task as will do today --------- */
        $(".will-do-today").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();

            $(".workload-management-errors").hide();
            $(".workload-management-flash-notice").hide();

            var workTodayButton = $(this);
            var $issue          = workTodayButton.closest(".issue");
            var issueId         = workTodayButton.attr("data-issue-id");
            var url             = "board/issue/" + issueId + "/will-do-today";

            var time_value = $issue.find(".time_for_today_value").html();
            time_value     = time_value ? time_value : $issue.find(".time_for_today_input").val();

            $.ajax({
                "type":     "POST",
                "url":       url,
                "dataType": "json",
                "data":      {time: time_value},
                "success":   function (response) {

                    if (response.success && response.success === true) {
                        $issue.find(".status").html(response.status);
                        $issue.find(".assignee").html(response.assignee);
                        $(".workload-management-flash-notice").show().html(response.info);
                        $issue.find(".time_for_today_value").html(time_value);

                        refreshTimeForTodayStatistic();
                    } else {
                        renderErrors(response.errors);
                    }
                    setTimeout(hideFlash, 5000);
                }
            });
        });

        /** --------- Mark task as in progress --------- */
        $(".mark-in-progress").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();

            $(".workload-management-errors").hide();
            $(".workload-management-flash-notice").hide();

            var workTodayButton = $(this);
            var $issue          = workTodayButton.closest(".issue");
            var issueId         = workTodayButton.attr("data-issue-id");
            var url             = "board/issue/" + issueId + "/mark-in-progress";

            $.ajax({
                "type":     "POST",
                "url":       url,
                "dataType": "json",
                "data":      {status: 1},
                "success":   function (response) {
                    handleStatusChangeResponse(response, $issue);
                }
            });
        });

        /** --------- Mark task as resolved --------- */
        $(".mark-resolved").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();

            $(".workload-management-errors").hide();
            $(".workload-management-flash-notice").hide();

            var workTodayButton = $(this);
            var $issue          = workTodayButton.closest(".issue");
            var issueId         = workTodayButton.attr("data-issue-id");
            var url             = "board/issue/" + issueId + "/mark-resolved";

            $.ajax({
                "type":     "POST",
                "url":       url,
                "dataType": "json",
                "data":      {status: 2},
                "success":   function (response) {
                    handleStatusChangeResponse(response, $issue);
                }
            });
        });

        function handleStatusChangeResponse(response, $issue) {
            if (response.success && response.success === true) {
                $issue.find(".status").html(response.status);
                $issue.find(".assignee").html(response.assignee);
                $(".workload-management-flash-notice").show().html(response.info);
                refreshTimeForTodayStatistic();
            } else {
                renderErrors(response.errors);
            }
            setTimeout(hideFlash, 5000);
        }

        function updateTimeForToday(issueId, timeForToday) {
            var $input = $(this);
            var url    = "board/issue/" + issueId + "/update-time-for-today";

            $.ajax({
                "type":     "POST",
                "url":       url,
                "dataType": "json",
                "data":      {time: timeForToday},
                "success":   function (response) {
                    if (response.success && response.success === true) {
                        if (response.is_changed) {
                            $(".workload-management-flash-notice").show().html(response.info);
                            $input.siblings(".time_for_today_value").html($input.val());
                            refreshTimeForTodayStatistic();
                        }
                    } else {
                        renderErrors(response.errors);
                    }
                    setTimeout(hideFlash, 5000);
                }
            });
        }

        function refreshTimeForTodayStatistic() {
            $.ajax({
                "type":     "GET",
                "url":       "board/time-for-today-statistic",
                "dataType": "json",
                "success":   function (response) {
                    if (response) {
                        $(".today_time_total").html(response.time_total);
                        $(".today_time_pipeline").html(response.time_pipeline);
                    }
                }
            });
        }

        function renderErrors(errors) {
            for (var i = 0; i < errors.length; i++) {
                var li = "<li>" + errors[i] + "</li>";
                $(".workload-management-errors").show().find("ul").append(li);
            }
        }

        function hideFlash() {
            $(".workload-management-errors").hide();
            $(".workload-management-flash-notice").hide();
            $(".workload-management-errors").find("ul").html('');
        }
    })(jQuery);
})();
