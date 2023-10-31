import subprocess
import time

# Define the MAC addresses and their respective actions
mac_actions = {
    '00:00:00:00:00:00': [
        'path/to/script_or_commmand'
    ],
    '00:00:00:00:00:00': [
        'path/to/script_or_commmand'
    ],
    '00:00:00:00:00:00': [
        'path/to/script_or_commmand'
    ],
    '00:00:00:00:00:00': [
        'path/to/script_or_commmand'
    ],
    '00:00:00:00:00:00': [
        'path/to/script_or_commmand'
    ]
    # Add more MAC addresses and their corresponding scripts as needed
}

while True:
    # Restart the Bluetooth adapter
    subprocess.run(['hciconfig', 'hci0', 'down'])
    subprocess.run(['hciconfig', 'hci0', 'up'])

    logfile = "ble.log"
    option = "--mac"
    mac = None

    # Run hcitool lescan for 10 sec and save output to log file
    scan_process = subprocess.Popen(['timeout', '10', 'stdbuf', '-oL', 'hcitool', 'lescan'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    printed_info = set()  # Keep track of printed MAC addresses

    for line in scan_process.stdout:
        line = line.decode('utf-8').strip()
        for mac_address, action_scripts in mac_actions.items():
            if mac_address in line and mac_address not in printed_info:
                # Display the MAC address and name of the device (if available) in green text
                print('\033[92m' + line + '\033[0m')

                # Execute both Python scripts and display the output in blue text
                for action_script in action_scripts:
                    script_process = subprocess.Popen(['python3', action_script], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                    script_output = script_process.stdout.read().decode('utf-8')
                    print('\033[91m' + script_output + '\033[0m')

                printed_info.add(mac_address)  # Add MAC address to printed set

    # Kill hcitool lescan after specified time
    scan_process.kill()

    # Wait for 10 seconds before rescanning
    time.sleep(10)
