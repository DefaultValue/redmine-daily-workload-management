(function () {
    "use strict";

    (function ($) {
        var oldTimeForTodayValue = 0;

        $(".time_for_today").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();

            $(".workload-management-flash-notice").hide();

            var $timeInput = $(this).find(".time_for_today_input");
            var $timeValue = $(this).find(".time_for_today_value");

            oldTimeForTodayValue = $timeValue.html();

            $timeInput.show().focus();
            $timeValue.hide();
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

        function updateTimeForToday(issueId, timeForToday) {
            var $input = $(this);
            var url    = "board/issue/"+issueId+"/update-time-for-today";

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
                            $(".today_time_value").html(response.today_time_value);
                        }
                    } else {
                        for (var i = 0; i < response.errors.length; i++) {
                            var li = "<li>"+response.errors[i]+"</li>";
                            $(".workload-management-errors").show().find("ul").append(li);
                        }
                        $input.siblings(".time_for_today_value").html(oldTimeForTodayValue);
                        oldTimeForTodayValue = 0;
                    }
                    setTimeout(hideFlash, 5000);
                }
            });
        }

        function hideFlash()
        {
            $(".workload-management-errors").hide();
            $(".workload-management-flash-notice").hide();
            $(".workload-management-errors").find("ul").html('');
        }

    })(jQuery);
})();
