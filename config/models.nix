{ lib, ... }: with lib; let
  mapActions = type: subtypes: listToAttrs (map (subtype: nameValuePair "${type}_${subtype}" {
    inherit type subtype;
  }) subtypes);
  ikeaEffects = [ "blink" "breathe" "okay" "channel_change" "finish_effect" "stop_effect" ];
  ikea = mapAttrs (_: model: model // { manufacturer = "IKEA"; }) {
    styrbar_remote = {
      name = "STYRBAR remote control (E2001/E2002)";
      platform = "mqtt";
      mqtt.zigbee2mqtt = {
        enable = true;
        url = "https://www.zigbee2mqtt.io/devices/E2001_E2002.html";
      };
      entities = {
        sensor = named {
          Battery.attributes.linkquality = { };
          Action = { };
        };
        binary_sensor = named {
          "Update Available".attributes."update.state" = { };
        };
        device_automation = mapActions "action" [
          "on" "brightness_move_up" "brightness_stop"
          "off" "brightness_move_down" # "brightness_stop"
          "arrow_left_click" "arrow_left_hold" "arrow_left_release"
          "arrow_right_click" "arrow_right_hold" "arrow_right_release"
        ];
      };
    };
    tradfri_remote = {
      name = "TRADFRI remote control (E1524/E1810)";
      platform = "mqtt";
      mqtt.zigbee2mqtt = {
        enable = true;
        url = "https://www.zigbee2mqtt.io/devices/E1524_E1810.html";
      };
      entities = {
        sensor = named {
          Battery.attributes.linkquality = { };
          Action = { };
        };
        binary_sensor = named {
          "Update Available".attributes."update.state" = { };
        };
        device_automation = mapActions "action" [
          "toggle" "toggle_hold"
          "brightness_up_click" "brightness_up_hold" "brightness_up_release"
          "brightness_down_click" "brightness_down_hold" "brightness_down_release"
          "arrow_left_click" "arrow_left_hold" "arrow_left_release"
          "arrow_right_click" "arrow_right_hold" "arrow_right_release"
        ];
      };
    };
    tradfri_switch = {
      name = "TRADFRI ON/OFF switch (E1743)";
      platform = "mqtt";
      mqtt.zigbee2mqtt = {
        enable = true;
        url = "https://www.zigbee2mqtt.io/devices/E1743.html";
      };
      entities = {
        sensor = {
          battery = {
            attributes = {
              linkquality = { };
            };
          };
          action = { };
          click = { };
        };
        binary_sensor.update_available = {
          attributes."update.state" = { };
        };
        device_automation = mapActions "action" [
          "on" "brightness_move_up" "brightness_stop"
          "off" "brightness_move_down" # "brightness_stop"
        ] // mapActions "click" [
          # NOTE: click is deprecated, and should be disabled: https://www.zigbee2mqtt.io/devices/E1743.html#deprecated-click-event
          "on" "brightness_up" "brightness_stop"
          "off" "brightness_down" # "brightness_stop"
        ];
      };
    };
    tradfri_shortcut_button = {
      name = "TRADFRI shortcut button (E1812)";
      platform = "mqtt";
      mqtt.zigbee2mqtt = {
        enable = true;
        url = "https://www.zigbee2mqtt.io/devices/E1812.html";
      };
      entities = {
        sensor = {
          battery = {
            attributes = {
              linkquality = { };
            };
          };
          action = { };
        };
        binary_sensor.update_available = {
          attributes."update.state" = { };
        };
        device_automation = mapActions "action" [
          "on" "brightness_move_up" "brightness_stop"
          "off" # double-tap
        ];
      };
    };
    rodret_dimmer = {
      name = "RODRET wireless dimmer/power switch (E2201)";
      platform = "mqtt";
      mqtt.zigbee2mqtt = {
        enable = true;
        url = "https://www.zigbee2mqtt.io/devices/E2201.html";
      };
      entities = {
        sensor = {
          battery = {
            attributes = {
              linkquality = { };
            };
          };
          action = { };
        };
        binary_sensor.update_available = {
          attributes."update.state" = { };
        };
        device_automation = mapActions "action" [
          "on" "brightness_move_up" "brightness_stop"
          "off" "brightness_move_down"
        ];
      };
    };
    tradfri_e26_white_1100 = {
      name = "TRADFRI LED bulb E26/27 1100/1055/1160 lumen, dimmable, white spectrum, opal white (LED2003G10)";
      platform = "mqtt";
      mqtt.zigbee2mqtt = {
        enable = true;
        url = "https://www.zigbee2mqtt.io/devices/LED2003G10.html";
      };
      entities = {
        light.light = {
          brightness = true;
          brightness_scale = 254;
          color_mode = true;
          effect = true;
          effect_list = ikeaEffects;
          max_mireds = 454;
          min_mireds = 250;
          supported_color_modes = [ "color_temp" ];
          attributes = {
            state = { };
            brightness = { };
            color_mode = { };
            color_temp = { };
          };
        };
        select.power_on_behavior = {
          options = [ "off" "previous" "on" ];
        };
        binary_sensor.update_available = {
          attributes = {
            linkquality = { };
            "update.state" = { };
          };
        };
      };
    };
    tradfri_e26_white_800 = {
      name = "TRADFRI LED bulb E26/E27 800/806 lumen, dimmable, white spectrum, clear";
      platform = "mqtt";
      mqtt.zigbee2mqtt = {
        enable = true;
        url = "https://www.zigbee2mqtt.io/devices/LED2004G8.html";
      };
      entities = {
        light.light = {
          brightness = true;
          brightness_scale = 254;
          color_mode = true;
          effect = true;
          effect_list = ikeaEffects;
          max_mireds = 454;
          min_mireds = 250;
          supported_color_modes = [ "color_temp" ];
          attributes = {
            state = { };
            brightness = { };
            color_mode = { };
            color_temp = { };
          };
        };
        select.power_on_behavior = {
          options = [ "off" "previous" "on" ];
        };
        binary_sensor.update_available = {
          attributes = {
            linkquality = { };
            "update.state" = { };
          };
        };
      };
    };
    tradfri_e27_white_1000 = {
      name = "TRADFRI LED bulb E27 1000 lumen, dimmable, white spectrum, opal white";
      platform = "mqtt";
      mqtt.zigbee2mqtt = {
        enable = true;
        url = "https://www.zigbee2mqtt.io/devices/LED1732G11.html";
      };
      entities = {
        light.light = {
          brightness = true;
          brightness_scale = 254;
          color_mode = true;
          effect = true;
          effect_list = ikeaEffects;
          max_mireds = 454;
          min_mireds = 250;
          supported_color_modes = [ "color_temp" ];
          attributes = {
            state = { };
            brightness = { };
            color_mode = { };
            color_temp = { };
          };
        };
        select.power_on_behavior = {
          options = [ "off" "previous" "on" ];
        };
        binary_sensor.update_available = {
          attributes = {
            linkquality = { };
            "update.state" = { };
          };
        };
      };
    };
    tradfri_e26_colour_800 = {
      name = "TRADFRI bulb E26/E27 CWS 800/806 lumen, dimmable, color, opal white (LED1924G9)";
      platform = "mqtt";
      mqtt.zigbee2mqtt = {
        enable = true;
        url = "https://www.zigbee2mqtt.io/devices/LED1924G9.html";
      };
      entities = {
        light.light = {
          brightness = true;
          brightness_scale = 254;
          color_mode = true;
          effect = true;
          effect_list = ikeaEffects;
          max_mireds = 454;
          min_mireds = 250;
          supported_color_modes = [ "xy" "color_temp" ];
          attributes = {
            state = { };
            brightness = { };
            color_mode = { };
            color_temp = { };
            "color.x" = { };
            "color.y" = { };
          };
        };
        select.power_on_behavior = {
          options = [ "off" "previous" "on" ];
        };
        binary_sensor.update_available = {
          attributes = {
            linkquality = { };
            "update.state" = { };
          };
        };
      };
    };
    tradfri_e26_800 = {
      name = "TRADFRI LED bulb E26/E27 806 lumen, dimmable, warm white (LED1836G9)";
      platform = "mqtt";
      mqtt.zigbee2mqtt = {
        enable = true;
        url = "https://www.zigbee2mqtt.io/devices/LED1836G9.html";
      };
      entities = {
        light.light = {
          brightness = true;
          brightness_scale = 254;
          effect = true;
          effect_list = ikeaEffects;
          attributes = {
            state = { };
            brightness = { };
          };
        };
        select.power_on_behavior = {
          options = [ "off" "previous" "on" ];
        };
        binary_sensor.update_available = {
          attributes = {
            linkquality = { };
            "update.state" = { };
          };
        };
      };
    };
    tradfri_e14_colour = {
      name = "TRADFRI LED bulb E14 470 lumen, opal, dimmable, white spectrum, color spectrum (LED1925G6)";
      platform = "mqtt";
      mqtt.zigbee2mqtt = {
        enable = true;
        url = "https://www.zigbee2mqtt.io/devices/LED1925G6.html";
      };
      entities = {
        light.light = {
          brightness = true;
          brightness_scale = 254;
          color_mode = true;
          effect = true;
          effect_list = ikeaEffects;
          max_mireds = 454;
          min_mireds = 250;
          supported_color_modes = [ "xy" "color_temp" ];
          attributes = {
            state = { };
            brightness = { };
            color_mode = { };
            color_temp = { };
            "color.x" = { };
            "color.y" = { };
          };
        };
        select.power_on_behavior = {
          options = [ "off" "previous" "on" ];
        };
        binary_sensor.update_available = {
          attributes = {
            linkquality = { };
            "update.state" = { };
          };
        };
      };
    };
    tradfri_gu10_white_380 = {
      name = "TRADFRI LED bulb GU10 345/380 lumen, dimmable, white spectrum (LED2005R5)";
      platform = "mqtt";
      mqtt.zigbee2mqtt = {
        enable = true;
        url = "https://www.zigbee2mqtt.io/devices/LED2005R5.html";
      };
      entities = {
        light.light = {
          brightness = true;
          brightness_scale = 254;
          color_mode = true;
          effect = true;
          effect_list = ikeaEffects;
          max_mireds = 454;
          min_mireds = 250;
          supported_color_modes = [ "color_temp" ];
          attributes = {
            state = { };
            brightness = { };
            color_mode = { };
            color_temp = { };
          };
        };
        select.power_on_behavior = {
          options = [ "off" "previous" "on" ];
        };
        binary_sensor.update_available = {
          attributes = {
            linkquality = { };
            "update.state" = { };
          };
        };
      };
    };
    tradfri_gu10_white_345 = ikea.tradfri_gu10_white_380;
    tradfri_gu10_colour = {
      name = "TRADFRI LED bulb GU10 345 lumen, dimmable, white spectrum, color spectrum (LED1923R5)";
      platform = "mqtt";
      mqtt.zigbee2mqtt = {
        enable = true;
        url = "https://www.zigbee2mqtt.io/devices/LED1923R5.html";
      };
      entities = {
        light.light = {
          brightness = true;
          brightness_scale = 254;
          color_mode = true;
          effect = true;
          effect_list = ikeaEffects;
          max_mireds = 454;
          min_mireds = 250;
          supported_color_modes = [ "xy" "color_temp" ];
          attributes = {
            state = { };
            brightness = { };
            color_mode = { };
            color_temp = { };
            "color.x" = { };
            "color.y" = { };
            "color.h" = { };
            "color.hue" = { };
            "color.s" = { };
            "color.saturation" = { };
          };
        };
        select.power_on_behavior = {
          options = [ "off" "previous" "on" ];
        };
        binary_sensor.update_available = {
          attributes = {
            linkquality = { };
            "update.state" = { };
          };
        };
      };
    };
    tradfri_gu10_380 = {
      name = "TRADFRI bulb GU10, warm white, 345/380 lm (LED2104R3)";
      platform = "mqtt";
      mqtt.zigbee2mqtt = {
        enable = true;
        url = "https://www.zigbee2mqtt.io/devices/LED2104R3.html";
      };
      entities = {
        light.light = {
          brightness = true;
          brightness_scale = 254;
          effect = true;
          effect_list = ikeaEffects;
          attributes = {
            state = { };
            brightness = { };
          };
        };
        select.power_on_behavior = {
          options = [ "off" "previous" "on" ];
        };
        binary_sensor.update_available = {
          attributes = {
            linkquality = { };
            "update.state" = { };
          };
        };
      };
    };
    tradfri_gu10_400 = {
      name = "TRADFRI LED bulb GU10 400 lumen, dimmable (LED1837R5)";
      platform = "mqtt";
      mqtt.zigbee2mqtt = {
        enable = true;
        url = "https://www.zigbee2mqtt.io/devices/LED1837R5.html";
      };
      entities = {
        light.light = {
          brightness = true;
          brightness_scale = 254;
          effect = true;
          effect_list = ikeaEffects;
          attributes = {
            state = { };
            brightness = { };
          };
        };
        select.power_on_behavior = {
          options = [ "off" "previous" "on" ];
        };
        binary_sensor.update_available = {
          attributes = {
            linkquality = { };
            "update.state" = { };
          };
        };
      };
    };
    tradfri_led_driver_10w = {
      name = "TRADFRI driver for wireless control (10 watt) (ICPSHC24-10EU-IL-1)";
      platform = "mqtt";
      mqtt.zigbee2mqtt = {
        enable = true;
        url = "https://www.zigbee2mqtt.io/devices/ICPSHC24-10EU-IL-1.html";
      };
      entities = {
        light.light = {
          brightness = true;
          brightness_scale = 254;
          effect = true;
          effect_list = ikeaEffects;
          attributes = {
            state = { };
            brightness = { };
          };
        };
        select.power_on_behavior = {
          options = [ "off" "previous" "on" ];
        };
        binary_sensor.update_available = {
          attributes = {
            linkquality = { };
            "update.state" = { };
          };
        };
      };
    };
    tradfri_led_driver_30w = {
      name = "TRADFRI driver for wireless control (30 watt) (ICPSHC24-30EU-IL-1)";
      platform = "mqtt";
      mqtt.zigbee2mqtt = {
        enable = true;
        url = "https://www.zigbee2mqtt.io/devices/ICPSHC24-30EU-IL-1.html";
      };
      entities = {
        light.light = {
          brightness = true;
          brightness_scale = 254;
          effect = true;
          effect_list = ikeaEffects;
          attributes = {
            state = { };
            brightness = { };
          };
        };
        select.power_on_behavior = {
          options = [ "off" "previous" "on" ];
        };
        binary_sensor.update_available = {
          attributes = {
            linkquality = { };
            "update.state" = { };
          };
        };
      };
    };
    starkvind = {
      name = "STARKVIND air purifier (E2007)";
      platform = "mqtt";
      mqtt.zigbee2mqtt = {
        enable = true;
        url = "https://www.zigbee2mqtt.io/devices/E2007.html";
      };
      entities = {
        fan.fan = {
          attributes = {
            fan_mode = { };
            fan_state = { };
            fan_speed = { };
          };
        };
        switch = {
          led_enable = {
          };
          child_lock = {
          };
        };
        sensor = named {
          "Fan speed" = {
          };
          "Pm25" = {
          };
          "Air quality" = {
            options = [
              "excellent" "good" "moderate" "poor" "unhealthy" "hazardous"
              "out_of_range" "unknown"
            ];
          };
        };
        binary_sensor = {
          replace_filter = { };
          update_available = {
            attributes = {
              "update.state" = { };
              linkquality = { };
            };
          };
        };
      };
    };
  };
  thirdreality = mapAttrs' (name: model: nameValuePair "thirdreality_${name}" (model // { manufacturer = "THIRDREALITY"; })) {
    power_meter_plug = {
      name = "Zigbee / BLE smart plug with power";
      platform = "mqtt";
      mqtt.zigbee2mqtt = {
        enable = true;
        url = "https://www.zigbee2mqtt.io/devices/3RSP02028BZ.html";
      };
      entities = let
        attributes = {
          ac_frequency = {};
          current = {};
          energy = {};
          linkquality = {};
          power = {};
          power_factor = {};
          power_on_behavior = {};
          update = {};
          update_available = {};
          voltage = {};
        };
      in {
        switch.switch = {
          inherit attributes;
        };
        sensor = named {
          Energy = {
            inherit attributes;
          };
          Frequency.disabled = true;
          Current.disabled = true;
          Voltage.disabled = true;
          "Power factor".disabled = true;
          "Power-on behavior".disabled = true;
          "Update state".disabled = true;
        };
        binary_sensor = named {
          "Update Available".disabled = true;
        };
      };
    };
  };
  sonoff_snzb03 = {
    platform = "mqtt";
    mqtt.zigbee2mqtt = {
      enable = true;
      url = "https://www.zigbee2mqtt.io/devices/SNZB-03.html";
    };
    battery.type = "cr2450";
    name = "SNZB-03";
    manufacturer = "Sonoff";
    entities = {
      binary_sensor = {
        occupancy = { };
        tamper = { };
      };
      sensor.battery = {
        attributes = named {
          Battery = { };
          "Battery low" = { };
          Linkquality = { };
          Occupancy = { };
          Tamper = { };
          Voltage = { };
        };
      };
    };
  };
  sonoff_snzb04 = {
    platform = "mqtt";
    mqtt.zigbee2mqtt = {
      enable = true;
      url = "https://www.zigbee2mqtt.io/devices/SNZB-04.html";
    };
    battery.type = "cr2032";
    name = "SNZB-04";
    manufacturer = "Sonoff";
    entities = {
      binary_sensor = {
        contact = { };
      };
      sensor.battery = {
        attributes = named {
          Battery = { };
          "Battery low" = { };
          Linkquality = { };
          Occupancy = { };
          Tamper = { };
          Voltage = { };
        };
      };
    };
  };
  tuya = {
    xh_001p = tuya.ts011f_plug_3;
    ts011f_plug_3 = recursiveUpdate tuya.ts011f_plug_2 {
      mqtt.zigbee2mqtt.url = "https://www.zigbee2mqtt.io/devices/TS011F_plug_3.html";
      entities = {
        select = named {
          "Power Outage Energy" = {
            options = [ "on" "off" "restore" ];
          };
        };
        sensor = named {
          Energy = {
            attributes = named {
              Current = { };
              Energy = { };
              Power = { };
              Voltage = { };
            };
          };
          Power = { };
        };
      };
    };
    ts011f_plug_2 = {
      platform = "mqtt";
      mqtt.zigbee2mqtt = {
        enable = true;
        url = "https://www.zigbee2mqtt.io/devices/TS011F_plug_2.html";
      };
      name = "TS011F";
      manufacturer = "TuYa";
      entities = {
        switch = {
          switch = { };
        } // named {
          "Child Lock" = { };
        };
        select = named {
          "Indicator Mode" = {
            options = [ "off" "off/on" "on/off" "on" ];
          };
        };
        binary_sensor = named {
          "Update Available" = {
            attributes = {
              linkquality = { };
            };
          };
        };
      };
    };
    ts0505b = rec {
      platform = "mqtt";
      mqtt.zigbee2mqtt = {
        enable = true;
        url = "https://www.zigbee2mqtt.io/devices/TS0505B.html";
      };
      name = "Zigbee RGB+CCT light (TS0505B)";
      manufacturer = "TuYa";
      power.rating_watts = 18;
      entities = {
        light.light = {
          brightness = true;
          brightness_scale = 254;
          color_mode = true;
          effect = true;
          effect_list = ikeaEffects;
          max_mireds = 500;
          min_mireds = 153;
          supported_color_modes = [ "xy" "color_temp" ];
          attributes = {
            state = { };
            brightness = { };
            color_mode = { };
            color_temp = { };
            color = { };
            linkquality = { };
          };
          settings.powercalc = {
            on.linear.max_power = power.rating_watts;
          };
        };
      };
    };
    ih012-rt01 = {
      platform = "mqtt";
      mqtt.zigbee2mqtt = {
        enable = true;
        url = "https://www.zigbee2mqtt.io/devices/IH012-RT01.html";
      };
      battery.type = "cr2450";
      name = "IH012-RT01";
      manufacturer = "TuYa";
      entities = {
        binary_sensor = {
          occupancy = {
            attributes = {
              sensitivity = { };
            };
          };
          tamper = { };
          battery_low = {
            attributes = {
              linkquality = { };
            };
          };
        };
        select = {
          keep_time = {
            options = [ 30 60 120 ];
          };
          sensitivity = {
            options = [ "low" "medium" "high" ];
          };
        };
      };
    };
    zms-102 = tuya.ih012-rt01; # ZigBee MINI motion sensor
    zm_35h_q = {
      platform = "mqtt";
      mqtt.zigbee2mqtt = {
        enable = true;
        url = "https://www.zigbee2mqtt.io/devices/ZM-35H-Q.html";
      };
      battery.type = "cr2450";
      name = "Motion sensor (ZM-35H-Q)";
      manufacturer = "TuYa";
      entities = {
        binary_sensor = {
          occupancy = {
            attributes = {
              sensitivity = { };
            };
          };
          tamper = { };
          battery_low = {
            attributes = {
              linkquality = { };
              battery = { };
            };
          };
        };
        sensor.battery = {
          attributes = named {
            Battery = { };
            "Battery low" = { };
            Linkquality = { };
            Occupancy = { };
            Tamper = { };
            Voltage = { };
          };
        };
        select = {
          keep_time = {
            options = [ 30 60 120 ];
          };
          sensitivity = {
            options = [ "low" "medium" "high" ];
          };
        };
      };
    };
    ih_f001 = {
      platform = "mqtt";
      mqtt.zigbee2mqtt = {
        enable = true;
        url = "https://www.zigbee2mqtt.io/devices/TS0203.html";
      };
      battery.type = "cr2032";
      name = "Door sensor (TS0203)";
      manufacturer = "TuYa";
      entities = {
        binary_sensor = {
          contact = { };
          tamper = { };
          tamper = { };
          battery_low = {
            attributes = {
              linkquality = { };
            };
          };
        };
        sensor.battery = {
          attributes = named {
            Battery = { };
            "Battery low" = { };
            Linkquality = { };
            Tamper = { };
            Voltage = { };
          };
        };
      };
    };
    ts0203_small = tuya.ih_f001;
    ts0203_large = tuya.ts0203_small // {
      battery = {
        type = "aaa";
        count = 2;
      };
    };
    zb-rgbcw = rec {
      platform = "mqtt";
      mqtt.zigbee2mqtt = {
        enable = true;
        url = "https://www.zigbee2mqtt.io/devices/ZB-RGBCW.html";
      };
      name = "Zigbee 3.0 LED-bulb, RGBW LED (ZB-RGBCW)";
      manufacturer = "Lonsonho";
      power.rating_watts = 9;
      entities = {
        light.light = {
          brightness = true;
          brightness_scale = 254;
          color_mode = true;
          max_mireds = 500;
          min_mireds = 153;
          supported_color_modes = [ "xy" "color_temp" ];
          attributes = {
            linkquality = { };
            power_on_behavior = { };
          };
          settings.powercalc = {
            on.linear.max_power = power.rating_watts;
          };
        };
        select.power_on_behavior = {
          options = [ "off" "on" "toggle" "previous" ];
        };
      };
    };
  };
  esphome = {
    bedroom_friend = {
      platform = "esphome";
      name = "bedroom";
      entity_name = "Bedroom";
      entities = {
        sensor = named {
          CO2 = { };
          Humidity = { };
          "Humidity 2" = { };
          PM1 = { };
          PM10 = { };
          "PM2.5" = { };
          Temperature = { };
          "Temperature 2" = { };
          Uptime = { };
          "Uptime Seconds" = { };
          "WiFi Signal" = { };
        };
        button = named {
          Restart = { };
        };
        binary_sensor = named {
          Status = { };
        };
      };
    };
    kitchen_friend = {
      platform = "esphome";
      name = "kitchen";
      entity_name = "Kitchen";
      entities = {
        sensor = named {
          CO2 = { };
          Humidity = { };
          "Humidity SEN55" = { };
          PM1 = { };
          PM4 = { };
          PM10 = { };
          "PM2.5" = { };
          VOC = { };
          NOx = { };
          Temperature = { };
          "Temperature SEN55" = { };
          Uptime = { };
          "Uptime Seconds" = { };
          "WiFi Signal" = { };
        };
        button = named {
          Restart = { };
        };
        binary_sensor = named {
          Status = { };
        };
      };
    };
    outdoor_friend = {
      platform = "esphome";
      name = "outdoor";
      entity_name = "Outdoor";
      entities = {
        sensor = named {
          eCO2 = { };
          TVOC = { };
        } // {
          inherit (esphome.bedroom_friend.entities.sensor)
            humidity temperature
            uptime uptime_seconds wifi_signal;
        };
        inherit (esphome.bedroom_friend.entities) button binary_sensor;
      };
    };
    dirty_friend = {
      platform = "esphome";
      name = "dirty-friend";
      entity_name = "Dirty";
      entities = {
        sensor = named {
          "Moisture 1" = { };
          "Moisture 2" = { };
          "Moisture 3" = { };
        } // {
          inherit (esphome.kitchen_friend.entities.sensor)
            humidity_sen55 temperature_sen55
            nox pm1 pm10 pm2_5 pm4 voc;
        };
        inherit (esphome.bedroom_friend.entities) button binary_sensor;
      };
    };
    s31 = {
      platform = "esphome";
      name = "S31";
      entities = {
        switch = named {
          Relay = { };
        };
        sensor = named {
          Voltage = { };
          Current = { };
          Power = { };
        } // {
          inherit (esphome.bedroom_friend.entities.sensor)
            uptime uptime_seconds wifi_signal;
        };
        button = {
          inherit (esphome.bedroom_friend.entities.button) restart;
        };
        binary_sensor = {
          inherit (esphome.bedroom_friend.entities.binary_sensor) status;
        };
      };
    };
    swb1 = rec {
      platform = "esphome";
      name = "SWB1";
      entity_name = name;
      entities = {
        switch = named {
          "Relay 1" = { };
          "Relay 2" = { };
          "Relay 3" = { };
          "Relay 4" = { };
        };
        light = named {
          LED = { };
        };
        sensor = {
          inherit (esphome.bedroom_friend.entities.sensor)
            uptime uptime_seconds wifi_signal;
        };
        button = {
          inherit (esphome.bedroom_friend.entities.button) restart;
        };
        binary_sensor = {
          inherit (esphome.bedroom_friend.entities.binary_sensor) status;
        } // named {
          Button = { };
        };
      };
    };
    esp32-led = rec {
      platform = "esphome";
      name = "ESP32 LED";
      entity_name = name;
      entities = {
        light.strip = { };
        sensor = {
          inherit (esphome.bedroom_friend.entities.sensor)
            uptime uptime_seconds wifi_signal;
        };
        button = {
          inherit (esphome.bedroom_friend.entities.button) restart;
        };
        binary_sensor = {
          inherit (esphome.bedroom_friend.entities.binary_sensor) status;
        };
      };
    };
    fornuftig = rec {
      platform = "esphome";
      name = "FÖRNUFTIG";
      entity_name = name;
      entities = {
        sensor = {
          inherit (esphome.bedroom_friend.entities.sensor)
            uptime uptime_seconds wifi_signal;
        };
        button = {
          inherit (esphome.bedroom_friend.entities.button) restart;
        };
        binary_sensor = {
          inherit (esphome.bedroom_friend.entities.binary_sensor) status;
          filter.name = "Filter";
        };
        fan.fan = {
          name = "Fan";
          speed_count = 3;
          settings.powercalc = {
            on.fixed = rec {
              power = 0.3;
              states_power = {
                "percentage|33" = power;
                "percentage|66" = 5.1;
                "percentage|100" = 12.2;
              };
            };
            off = 0.2;
          };
        };
      };
    };
    kittylamp = {
      platform = "esphome";
      name = "Kittylamp";
      entities = {
        light.light = {
          settings.powercalc = rec {
            on.linear = {
              min_power = off;
              max_power = 1.5; # 100% white
              # 33% white: 0.4W
              # 100% colour: 1.15W
              # 100% red: 0.8W
            };
            off = 0.35;
          };
        };
        sensor = {
          inherit (esphome.bedroom_friend.entities.sensor)
            uptime uptime_seconds wifi_signal;
        };
        button = {
          inherit (esphome.bedroom_friend.entities.button) restart;
        };
        binary_sensor = {
          inherit (esphome.bedroom_friend.entities.binary_sensor) status;
        };
      };
    };
    espresense = rec {
      platform = "espresense";
      name = "ESPresense";
      entity_name = name;
      entities = {
        sensor = named {
          Uptime = { };
          "Free Mem" = { };
        };
        button = named {
          Restart = { };
        };
      };
    };
  };
  wled = {
    platform = "wled";
    name = "WLED";
    entities = {
      light.light = {
      };
    };
  };
  companion = rec {
    companion_ios = {
      platform = "companion";
      companion.os = "ios";
      name = "Mobile App (iOS)";
      entities = {
        device_tracker.device_tracker = { };
        sensor = named {
          Activity = { };
          "Average Active Pace" = { };
          "Battery Level" = { };
          "Battery State".attributes = named {
            "Low Power Mode" = { };
          };
          BSSID = { };
          "Connection Type" = { };
          Distance = { };
          "Last Update Trigger" = { };
          "SIM 1".attributes = named {
            "Allows VoIP" = { };
            "Carrier ID" = { };
            "Carrier Name" = { };
            "Current Radio Technology" = { };
            "ISO Country Code" = { };
            "Mobile Country Code" = { };
            "Mobile Network Code" = { };
          };
          "SIM 2" = { };
          SSID = { };
          Steps = { };
          Storage.attributes = named {
            Available = { };
            "Available (Important)" = { };
            "Available (Opportunistic)" = { };
            Total = { };
          };
        };
        binary_sensor = named {
          Focus = { };
        };
        notify.notify = {
          name_prefix = "Mobile App";
        };
      };
    };
    companion_android = {
      platform = "companion";
      companion.os = "android";
      name = "Mobile App (Android)";
      entities = {
        inherit (companion_ios.entities) device_tracker notify;
        sensor = named {
          "Battery Level" = { };
          "Battery State" = { };
        };
      };
    };
  };
  midea_ac = {
    platform = "midea";
    name = "Air Conditioner 00000Q17(32773)";
    entities = {
      climate.climate = {
        settings.powercalc = todo rec {
          off = 2;
          on.fixed.states_power = {
            fan_only = 25;
            eco = 1000;
            cool = 1350;
            inherit off;
            #TODO: "attr|cooling" = cool; # NOTE: need template or automation to check if temp is under target temp, because it won't say :(
          };
        };
      };
      sensor = named {
        "Outdoor Temperature" = { };
        "Indoor Temperature" = { };
      };
      binary_sensor = {
        full_dust.name = "Full of Dust";
      };
      switch = named {
        Power = { };
      };
    };
  };
  systemd2mqtt = {
    name = "systemd2mqtt";
    manufacturer = "arcnmx";
    platform = "mqtt";
    entities = {
      switch.switch = { };
    };
  };
  apple_tv = {
    apple_tv = {
      platform = "apple_tv";
      name = "Apple TV";
    };
    homepod_mini = apple_tv.apple_tv // {
      name = "HomePod Mini";
      entities = {
        media_player.media_player = {
          attributes = {
            volume_level = { };
            supported_features = { };
          };
        };
        remote.remote = {
          attributes = {
            supported_features = { };
          };
        };
      };
    };
  };
  androidtv = {
    androidtv = {
      platform = "androidtv";
      name = "Android TV";
      entities.media_player.media_player = {
        attributes = {
          supported_features = { };
        };
      };
    };
    androidtv_adb = recursiveUpdate androidtv.androidtv {
      name = "Android TV ADB";
      manufacturer = "Google";
      entities.media_player.media_player = {
        attributes = {
          app_name = { };
          adb_response = { };
          hdmi_input = { };
        };
      };
    };
    androidtv_remote = recursiveUpdate androidtv.androidtv {
      name = "Android TV Remote";
      manufacturer = "Google";
      entities = {
        media_player.media_player = {
          attributes = {
            app_name = { };
            app_id = { };
            volume_level = { };
            is_volume_muted = { };
          };
        };
        remote.remote = {
          attributes = {
            current_activity = { };
            activity_list = { };
          };
        };
      };
    };
    androidtv_chromecast = androidtv.androidtv_remote // {
      name = "Android TV Chromecast";
      manufacturer = "Google";
    };
  };
  nfandroidtv = {
    platform = "nfandroidtv";
    name = "Notifications for Android TV / Fire TV";
    url = "https://www.home-assistant.io/integrations/nfandroidtv/";
    entities = {
      notify.notify = {
      };
    };
  };
  google_cast = {
    cast = {
      platform = "cast";
      entities.media_player.media_player = {
        attributes = {
          volume_level = { };
          is_volume_muted = { };
          media_content_id = { };
          media_content_type = { };
          media_duration = { };
          media_position = { };
          media_title = { };
          media_artist = { };
          media_album_name = { };
          app_id = { };
          app_name = { };
          device_class = { };
          entity_picture = { };
          entity_picture_local = { };
          friendly_name = { };
          supported_features = { };
        };
      };
    };
    cast_chromecast = recursiveUpdate google_cast.cast {
      name = "Chromecast";
      manufacturer = "Google";
    };
    cast_tv = recursiveUpdate google_cast.cast {
      name = "Smart TV";
    };
    cast_group = recursiveUpdate google_cast.cast {
      name = "Google Cast Group";
      manufacturer = "Google";
    };
    cast_nest_hub = recursiveUpdate google_cast.cast {
      name = "Google Nest Hub";
      manufacturer = "Google";
    };
    cast_nest_mini = recursiveUpdate google_cast.cast {
      name = "Google Nest Mini";
      manufacturer = "Google";
    };
  };
  google_assistant = {
    platform = "google_assistant";
    name = "Google Assistant";
    entities.button = named {
      "Synchronize Devices" = { };
    };
  };
  forecast = {
    name = "Forecast";
    manufacturer = "Met.no";
    url = "https://www.met.no/en";
    platform = "home";
    service = true;
    entities.weather = {
      weather = {
        name = "Forecast";
      };
    } // named {
      Hourly = { };
    };
  };
  environment_canada = {
    name = "Environment Canada";
    manufacturer = "Environment Canada";
    url = "https://weather.gc.ca/";
    platform = "home";
    service = true;
    entities = {
      sensor = named {
        Advisory = { };
        AQHI = { };
        "Barometric pressure" = { };
        "Chance of precipitation" = { };
        "Current condition" = { };
        "Dew point" = { };
        Endings = { };
        "High temperature" = { };
        Humidex = { };
        Humidity = { };
        "Icon code" = { };
        "Low temperature" = { };
        "Normal high temperature" = { };
        "Normal low temperature" = { };
        "Observation time" = { };
        "Precipitation yesterday" = { };
        Statements = { };
        Summary = { };
        Temperature = { };
        Tendency = { };
        "UV index" = { };
        Visibility = { };
        Warnings = { };
        Watches = { };
        "Wind bearing" = { };
        "Wind chill" = { };
        "Wind direction" = { };
        "Wind gust" = { };
        "Wind speed" = { };
        Radar.disabled = true;
        "Hourly forecast".disabled = true;
      };
      weather.forecast = { };
    };
  };
  homekit_bridge = {
    name = "HomeKit Bridge";
    manufacturer = "Home Assistant";
    platform = "homekit";
    service = true;
  };
  brother = {
    HL-L2370DW = rec {
      name = "HL-L2370DW";
      entity_name = name;
      manufacturer = "Brother";
      platform = "brother_printer";
      entities.sensor = named {
        "Black toner remaining" = { };
        "Drum remaining life" = { };
        "Duplex unit pages counter" = { };
        "Page counter" = { };
        Status = { };
        Uptime = { };
      };
    };
  };
  ipp = {
    name = "Internet Printing Protocol (IPP)";
    platform = "ipp";
    entities.sensor.sensor = {
      attributes = named {
        Info = { };
        Serial = { };
        Location = { };
        "State message" = { };
        "State reason" = { };
        "Command set" = { };
        "Uri supported" = { };
      };
    };
  };
  beacons = {
    beacon_bc021 = {
      name = "BC021";
      manufacturer = "Blue Charm Beacons";
      timeout = 30;
    };
    beacon_android_companion = {
      name = "Home Assistant Companion App (Android)";
      manufacturer = "Home Assistant";
      timeout = 20;
    };
    beacon_ios = {
      name = "iOS";
      manufacturer = "Apple";
      timeout = 15;
    };
    beacon_tile = {
      name = "Tile";
      manufacturer = "Tile";
      ble.espresense.macPrefix.service = "tile";
      timeout = 45;
    };
    beacon_sonos = {
      name = "Sonos";
      manufacturer = "Sonos";
      ble.espresense.macPrefix.service = "sonos";
    };
    beacon_itag = {
      ble.espresense.macPrefix.service = "itag";
    };
    beacon_trackr = {
      ble.espresense.macPrefix.service = "trackr";
    };
    beacon_tractive = {
      ble.espresense.macPrefix.service = "tractive";
    };
    beacon_vanmoof = {
      ble.espresense.macPrefix.service = "vanmoof";
    };
    beacon_meater = {
      ble.espresense.macPrefix.service = "meater";
    };
    beacon_nut = {
      ble.espresense.macPrefix.service = "nut";
    };
    beacon_flora = {
      ble.espresense.macPrefix.service = "flora";
    };
    beacon_garmin = {
      ble.espresense.macPrefix.manufacturer = "garmin";
    };
    beacon_itrack = {
      ble.espresense.macPrefix.manufacturer = "iTrack";
    };
    beacon_mifit = {
      ble.espresense.macPrefix.manufacturer = "mifit";
    };
    beacon_samsung = {
      ble.espresense.macPrefix.manufacturer = "samsung";
    };
    beacon_mitherm = {
      ble.espresense.macPrefix.serviceData = "miTherm";
    };
    beacon_smarttag = {
      ble.espresense.macPrefix.serviceData = "smarttag";
    };
  };
  grocy = {
    platform = "nfandroidtv";
    name = "Custom Grocy integration";
    url = "https://github.com/custom-components/grocy";
    entities = {
      binary_sensor = named {
        "Expiring products" = { };
        "Expired products" = { };
        "Missing products" = { };
        "Overdue batteries" = { };
        "Overdue chores" = { };
        "Overdue products" = { };
        "Overdue tasks" = { };
      };
      sensor = named {
        Batteries = { };
        Chores = { };
        "Meal plan" = { };
        "Shopping list" = { };
        Stock = { };
        Tasks = { };
      };
    };
  };
  octoprint = {
    name = "OctoPrint";
    manufacturer = "OctoPrint";
    platform = "octoprint";
    entities = {
      sensor = named {
        "Actual bed temp" = { };
        "Actual tool0 temp" = { };
        "Actual W temp" = { };
        "Target bed temp" = { };
        "Target tool0 temp" = { };
        "Target W temp" = { };
        "Current State" = { };
        "Estimated Finish Time" = { };
        "Job Percentage" = { };
        "Start Time" = { };
      };
      binary_sensor = named {
        Printing = { };
        "Printing Error" = { };
      };
      button = named {
        "Pause Job" = { };
        "Reboot System" = { };
        "Restart Octoprint" = { };
        "Resume Job" = { };
        "Shutdown System" = { };
        "Stop Job" = { };
      };
      camera = named {
        Camera = { };
      };
    };
  };
  moonraker = {
    name = "Moonraker";
    manufacturer = "Klipper";
    platform = "moonraker";
    entities = {
      sensor = named {
        "Bed Power" = { };
        "Bed Target" = { };
        "Bed Temperature" = { };
        "Current Display Message" = { };
        "Current Layer" = { };
        "Current Print State" = { };
        "Extruder Power" = { };
        "Extruder Target" = { };
        "Extruder Temperature" = { };
        "Fan speed" = { };
        "Filament Used" = { };
        "Filename" = { };
        "Hotend Fan" = { };
        "Jobs in queue" = { };
        "Longest Print" = { };
        "Object Height" = { };
        "Print Duration" = { };
        "Print ETA" = { };
        "Print Projected Total Duration" = { };
        "Print Time Left" = { };
        "Printer Message" = { };
        "Printer State" = { };
        "Progress" = { };
        "Queue State" = { };
        "Slicer Print Duration Estimate" = { };
        "Slicer Print Time Left" = { };
        "Speed factor" = { };
        "Thumbnail" = { };
        "Toolhead position X" = { };
        "Toolhead position Y" = { };
        "Toolhead position Z" = { };
        "Total Layer" = { };
        "Totals Filament Used" = { };
        "Totals jobs" = { };
        "Totals Print Time" = { };
      };
      binary_sensor = named {
        "Update Available" = { };
      };
      button = named {
        "Cancel Print" = { };
        "Pause Print" = { };
        "Resume Print" = { };
        "Emergency Stop" = { };
        "Firmware Restart" = { };
        "Server Restart" = { };
        "Host Restart" = { };
        "Host Shutdown" = { };
        "Machine Update Refresh" = { };
        "Macro Beep" = { };
        "Macro Filament Load" = { };
        "Macro Filament Unload" = { };
        "Macro Low Temp Check" = { };
        "Macro Pid Bed" = { };
        "Macro Pid Extruder" = { };
        "Macro Print Stop" = { };
        "Macro Start Print" = { };
        # TODO: many more we don't use...
      };
      number = named {
        "Output Pin Beeper" = { };
      };
      camera = named {
        Printer = { };
        Thumbnail = { };
      };
    };
  };
in {
  config.model = mkMerge [
    ikea thirdreality tuya esphome brother google_cast apple_tv androidtv companion beacons
    {
      inherit
        systemd2mqtt google_assistant ipp forecast environment_canada
        midea_ac homekit_bridge
        sonoff_snzb03 sonoff_snzb04 wled
        nfandroidtv
        grocy
        octoprint moonraker
        ;
    }
  ];
}
