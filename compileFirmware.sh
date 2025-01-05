### @file
### @brief [Brief description of what the file does]
### 
### [Detailed description of the file's purpose and functionality]
### 
### @author [Juan A. Valle]
### @date [2025/01/05]
### @version [0.1]
### @Project: [KlintLand Home Assistant EspHome Nodes]
 
#!/bin/bash

# Activate the virtual environment
# Check vevn exists, if not, create it
if [ ! -d "venv" ]; then
    echo "Creating virtual environment"
    python3 -m venv venv
fi

## check if venv already activated
if [ -z "${VIRTUAL_ENV}" ]; then
    echo "Activating virtual environment"  
    source venv/bin/activate
else
    echo "Virtual environment already activated"
    exit 1
fi

# Display the current version of esphome
echo "espHome $(esphome --version)"

# Create a menu option by listing all folders inside the configurations folder (give a number to each one) and let me choose one by numbering them and selecting the number take all yaml files in that folder and compile them
# List all folders inside the configurations folder
CONFIGURATIONS_FOLDER="./configurations"
CONFIGURATIONS=($(ls -d ${CONFIGURATIONS_FOLDER}/*/))

# Display the list of configurations
echo ""
echo "| Select a configuration to compile:"
echo "|"
for i in "${!CONFIGURATIONS[@]}"; do
    echo "|  $i: ${CONFIGURATIONS[$i]}"
done
echo "|"

# Read the user input
read -p "| > Select node to compile: " CONFIGURATION_NUMBER

# Check if the input is a number
if ! [[ "${CONFIGURATION_NUMBER}" =~ ^[0-9]+$ ]]; then
    echo "Invalid input. Please enter a number."
    exit 1
fi

# Check if the number is within the range
if [ "${CONFIGURATION_NUMBER}" -lt 0 ] || [ "${CONFIGURATION_NUMBER}" -ge "${#CONFIGURATIONS[@]}" ]; then
    echo "Invalid input. Please enter a number between 0 and $(( ${#CONFIGURATIONS[@]} - 1 ))."
    exit 1
fi

# Get the selected configuration folder
SELECTED_CONFIGURATION="${CONFIGURATIONS[${CONFIGURATION_NUMBER}]}"
echo "Selected configuration: ${SELECTED_CONFIGURATION}"

# Compile all yaml files in the selected configuration folder. Select only .yaml files
for yaml_file in "${SELECTED_CONFIGURATION}"/*.yaml; do
    esphome compile "${yaml_file}"
done

# Check if the compilation was successful
if [ $? -eq 0 ]; then
    echo "Compilation successful"
else
    echo "Compilation failed"
    exit 1
fi

# Copy the firmware.bin file to the current folder with a name based on the yaml file
# Define the esphome name
ESPHOME_NAME=$(basename ${SELECTED_CONFIGURATION})
ESPHOME_NAME=${ESPHOME_NAME%/}

# Define the source and destination paths
SOURCE_PATH="./.pioenvs/${ESPHOME_NAME}/firmware.bin"
DESTINATION_PATH="./firmware-${ESPHOME_NAME}.bin"

# Copy the firmware.bin file to the current folder
cp "${SOURCE_PATH}" "${DESTINATION_PATH}"

# Check if the copy was successful
if [ $? -eq 0 ]; then
    echo "Firmware copied successfully to ${DESTINATION_PATH}"
else
    echo "Failed to copy firmware"
    exit 1
fi







