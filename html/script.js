(() => {
    [
        ".vehicle_gear",
        ".speed",
        ".speed_text",
        ".vehicle_options",
        ".fuel-progress",
        ".fuel-container",
        "#fuel-icon",
        ".fuel-percentage"
    ].forEach(element => $(element).fadeOut());
    $("#todo").css("opacity", "0.0");
});
function update_stats (selector, value) {
    $(`${selector}-percent`).html(Math.round(value) + "");
    $(`${selector}-level`).css("width", value + "");
};
function toggle_element(selector, condition) {
    const element = document.querySelector(selector);
    if (element) {
        element.style.display = condition ? 'block' : 'none';
    } else {
        console.error(`toggle_element : Element with selector '${selector}' not found.`);
    }
};
$(function () {
    window.addEventListener("message", function (event) {
        (event.data.clock_type == "mph" ? $('.speed_text').html("MPH") : $('.speed_text').html("KM/H"));
        $('#watermark').attr('src', event.data.logo);
        $("#todo").css("opacity", event.data.pauseMenu ? "0.0" : "1.0");
        if (event.data.in_vehicle) {
            var selector2 = document.querySelector("#ui")
            selector2.style = "opacity:1.0; left:17%; margin-top:1vh; bottom:0%; display:block;bottom:2%;overflow: hidden;"
            $("#ox").css("opacity", "0.0");
            update_stats("#armour", event.data.armour);
            update_stats("#health", event.data.health);
            update_stats("#food", event.data.food);
            update_stats("#thirst", event.data.thirst);
            update_stats("#stress", event.data.stress);
            update_stats("#userid", event.data.userid);
        } else {
            $("#ox").css("opacity", "1.0");
            var selector2 = document.querySelector("#ui")
            selector2.style = "opacity:1.0;"
        }
        if (event.data.isinthewater || event.data.isinthewater === 1) {
            $(".oxygen").css("opacity", "0.0");
            $(".underwater_time").css("opacity", "1.0");
            update_stats("#armour", event.data.armour);
            update_stats("#health", event.data.health);
            update_stats("#food", event.data.food);
            update_stats("#thirst", event.data.thirst);
            update_stats("#underwater_time", event.data.underwater_time);
        } else {
            update_stats("#oxygen", event.data.oxygen);
            $(".oxygen").css("opacity", "1.0");
            $(".underwater_time").css("opacity", "0.0");
        }
        toggle_element("#main_content", event.data.hide_hud);
        toggle_element("#main_content", !event.data.show_hud);
        toggle_element("#bars", event.data.start_cinematic);
        toggle_element("#main_content", !event.data.stop_cinematic);
    });
    window.addEventListener('message', function (event) {
        const v = event.data;
        if (v.type === 'seatbelt:toggle' && (v.toggle !== null || v.checkIsVeh != null || v.checkIsVeh === 1 === true)) {
            $('.seatbelt').html(v.checkIsVeh ? `<img src="./img/seatbelt_${v.toggle ? 'on' : 'off'}.png" id="seatbelt">` : `<img src="./img/seatbelt_off.png" id="seatbelt">`);
        }
        if (v.vehicle_lights == 1) {
            $('#lights').css({ color: 'white', 'text-shadow': '0 0 0 white' });
        } else if (v.high_beam == 1) {
            $('#lights').css({ color: 'white', 'text-shadow': '0 0 .4vw white' });
        } else {
            $('#lights').css({ color: v.vehicle_lights == 0 && v.high_beam == 0 ? '#928b94' : 'inherit', 'text-shadow': '0 0 0 white' });
        }
        $('#vehicle_lock').css({ color: v.locked == 1 ? 'rgb(0, 235, 74)' : v.locked == 2 ? 'rgb(235, 0, 51)' : 'inherit' });
        $('#vehicle_damage').css({ color: v.damage <= 900 ? 'rgb(235, 0, 51)' : v.damage > 900 ? '#928b94' : 'inherit' });
        if (v.type === 'carhud:update') {
            if (v.isInVehicle) {
                [".vehicle_options", ".vehicle_gear", ".speed", ".speed_text", ".fuel-progress", ".fuel-container", "#fuel-icon", ".fuel-percentage"].forEach(element => $(element).fadeIn());
                $(".vehicle_gear").html(Math.round(v.gear) + "");
                $(".speed").html(('000' + Math.round(v.speed)).substr(-3));
                $(".fuel-progress").css("width", Math.round(v.fuel) + "%");
                $(".fuel-percentage").html(Math.round(v.fuel) + "%");
            } else {
                [".vehicle_options", ".vehicle_gear", ".speed", ".speed_text", ".fuel-progress", ".fuel-container", "#fuel-icon", ".fuel-percentage"].forEach(element => $(element).fadeOut());
            }
            if (Math.round(v.speed) === 0) {
                $(".speed").html("000");
            }
        }
    });
});