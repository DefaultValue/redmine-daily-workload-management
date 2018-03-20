(function () {
    "use strict";

    (function ($) {
        $(".will-do-today").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();

            $(".workload-management-errors").hide();
            $(".workload-management-flash-notice").hide();

            var workTodayButton = $(this);
            var issueId         = workTodayButton.attr("data-issue-id");
            var url             = "board/issue/" + issueId + "/will-do-today";

            $.ajax({
                "type":     "POST",
                "url":       url,
                "dataType": "json",
                "data":      {time: workTodayButton.closest(".issue").find(".time_for_today_value").html()},
                "success":   function (response) {
                    if (response.success && response.success === true) {
                        var closest_issue = workTodayButton.closest(".issue");
                        closest_issue.find(".status").html(response.status);
                        closest_issue.find(".assignee").html(response.assignee);
                        $(".workload-management-flash-notice").show().html(response.info);
                        refreshTimeForTodayStatistic();
                    } else {
                        for (var i = 0; i < response.errors.length; i++) {
                            var li = "<li>"+response.errors[i]+"</li>";
                            $(".workload-management-errors").show().find("ul").append(li);
                        }
                    }
                    setTimeout(hideFlash, 5000);
                }
            });
        });

        /** @TODO merge with other file */
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

        function hideFlash() {
            $(".workload-management-errors").hide();
            $(".workload-management-flash-notice").hide();
            $(".workload-management-errors").find("ul").html('');
        }
    })(jQuery);
})();
