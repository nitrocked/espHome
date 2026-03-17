# Klint Land - ESPHome Nodes 🏠

This repository contains the YAML configurations for the ESPHome nodes deployed in the "Klint Land" home automation project.

The main goal is to create custom microcontroller-based devices (ESP8266/ESP32) that fully integrate with Home Assistant, solving specific use cases that commercial devices do not cover.

## ⚠️ Project Status

| Node | Status | Description |
| :--- | :--- | :--- |
| **garage-lock** | ✅ **Stable** | Electric lock controller with pulse filtering logic and light control. |
| *others* | 🧪 *Testing* | The rest of the files are peripheral tests, diagrams, and non-functional prototypes. |

---

## 🔐 Node: Garage Lock (`garage-lock.yaml`)

This is the main and currently operational node. Its function is to manage a garage door lock and adjacent lighting, solving a specific limitation of the automatic door motor.

### The Problem
The existing automatic door motor **does not have a dedicated output to control an electric lock**. However, it does have a 24V output for an operation light (flashing/warning light) that blinks while the door is in motion.

Connecting the electric lock directly to the warning light would cause the lock to repeatedly open and close with the blinking, which is undesirable and harmful to the mechanism.

### The Solution
An ESP8266 (NodeMCU) node has been implemented to act as a smart intermediary:

1.  **Signal Input:** It reads the pulses from the 24V operation light (adapted to a logic level for the ESP).
2.  **"One-Shot" Logic:** Using *lambdas* and global variables in ESPHome, the system detects the **first light pulse**.
3.  **Execution:** It activates the electric lock immediately.
4.  **Blocking (Debounce):** Once activated, the system enters a blocking period (configurable, default is 5 seconds). During this time, it ignores subsequent blinks from the 24V light, ensuring the lock is only triggered once per opening cycle.

### Hardware Features

*   **Board:** ESP8266 (NodeMCU).
*   **Input Sensor (GPIO14):** Detects the 24V signal from the motor (labeled as "12V Input" in the code).
*   **Lights Output (GPIO13):** Relay to control the porch lighting ("Porche Lights").
*   **Lock Output (GPIO16):** Relay for the electric lock ("Gate Lock").

### Dynamic Configuration (Variables)
The node exposes controls in Home Assistant to adjust the logic without needing to recompile:

*   **Block Time (s):** Time to ignore pulses after the first activation (prevents the "machine gun" effect from blinking).
*   **Lock Delay Time (ms):** Short delay before activating the relay after detecting the signal.
*   **Lock Time (ms):** Time the lock relay remains closed (pulse duration).

### Main Logic Snippet

```yaml
binary_sensor:
  - platform: gpio
    # ...
    on_press:
      - if:
          condition:
            lambda: return !id(blocked_lock); # Only if not blocked
          then:
            - lambda: id(blocked_lock) = true; # Block immediately
            - delay: !lambda "return id(lock_delay_time);"
            - switch.turn_on: relay_output_lock
            - delay: !lambda "return id(block_time) * 1000;" # Wait for the block time
            - lambda: id(blocked_lock) = false; # Unblock for the next cycle
```

---

## 🛠️ Installation & Use

1.  Clone repository.
2.  Ensure configure values in `secrets.yaml` for WiFi y OTA:
    ```yaml
    wifi_ssid_1: "..."
    wifi_password_1: "..."
    ota_password: "..."
    # etc...
    ```
3.  Compile and generate firmware and OTA firmware by running script:
    ```bash
    ./compileFirmware.sh
    ```
4. Upload to your hardware by your prefered method
