# echo_env.py
import os

pdm_env = os.environ.get('PDM_ENV', 'development')
port = os.environ.get('PORT')
region = os.environ.get('REGION')
secret_password = os.environ.get('SECRET_PASSWORD')

print("Value of PDM_ENV:", pdm_env)
print("Value of PORT:", port)
print("Value of REGION:", region)
print("Value of SECRET_PASSWORD:", secret_password)
