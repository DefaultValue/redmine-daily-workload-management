(function () {
    "use strict";

    (function ($) {
        $(".mark-resolved").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();

            $(".workload-management-errors").hide();
            $(".workload-management-flash-notice").hide();

            var workTodayButton = $(this);
            var issueId         = workTodayButton.attr("data-issue-id");
            var url             = "board/issue/" + issueId + "/mark-resolved";

            $.ajax({
                "type":     "POST",
                "url":       url,
                "dataType": "json",
                "data":      {status: 2},
                "success":   function (response) {
                    console.log(response);
                    if (response.success && response.success === true) {
                        var closest_issue = workTodayButton.closest(".issue");
                        closest_issue.find(".status").html(response.status);
                        $(".workload-management-flash-notice").show().html(response.info);
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

        function hideFlash() {
            $(".workload-management-errors").hide();
            $(".workload-management-flash-notice").hide();
            $(".workload-management-errors").find("ul").html('');
        }
    })(jQuery);
})();
