# echo_env.py
import os

pdm_env_value = os.environ.get('PDM_ENV')
region = os.environ.get('REGION')
secret_password = os.environ.get('SECRET_PASSWORD')
use_database = os.environ.get('USE_DATABASE')

print("Value of PDM_ENV:", pdm_env_value)
print("Value of REGION:", region)
print("Value of SECRET_PASSWORD:", secret_password)
print("Value of USE_DATABASE:", use_database)