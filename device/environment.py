# Read configuration file
import configparser
from os import path

# Configuration parser
envfile = configparser.ConfigParser()

# Environment file
environment_file = path.join("../environment.ini")

# Read the environment file
envfile.read(environment_file)

# platformio.ini
# Import the current working construction
# environment to the `env` variable.
Import("projenv")

# Parse strings
def envstr(string):
    return r"\"" + string + r"\""

# Append environment variables
projenv.Append(CPPDEFINES=[
    "ENV_OK",
    ("ENV_DEVICE_NAME", envstr(envfile["device"]["name"])),
    
    ("ENV_SERVICES_AMBIENCE_UUID", envstr(envfile["services.ambience"]["uuid"])),
    ("ENV_SERVICES_AMBIENCE_TEMPERATURE_UUID", envstr(envfile["services.ambience.temperature"]["uuid"])),
    ("ENV_SERVICES_AMBIENCE_HUMIDITY_UUID", envstr(envfile["services.ambience.humidity"]["uuid"])),
    
    ("ENV_SERVICES_LIGHT_UUID", envstr(envfile["services.light"]["uuid"])),
    ("ENV_SERVICES_LIGHT_VALUE_UUID", envstr(envfile["services.light.value"]["uuid"])),
    
    ("ENV_SERVICES_DEBUG_UUID", envstr(envfile["services.debug"]["uuid"])),
    ("ENV_SERVICES_DEBUG_FREE_HEAP_UUID", envstr(envfile["services.debug.free_heap"]["uuid"])),
])