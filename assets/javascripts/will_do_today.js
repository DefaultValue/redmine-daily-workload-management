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
                        workTodayButton.closest(".issue").find(".status").html(response.status);
                        $(".workload-management-flash-notice").show().html(response.info);
                        $(".today_time_value").html(response.today_time_value);
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

        function hideFlash()
        {
            $(".workload-management-errors").hide();
            $(".workload-management-flash-notice").hide();
            $(".workload-management-errors").find("ul").html('');
        }
    })(jQuery);
})();
