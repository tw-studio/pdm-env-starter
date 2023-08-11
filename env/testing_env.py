# testing_env.py
from env.common_env import common_settings
from env._development_secrets import (
    secret_password,
)

settings = {
    **common_settings,
    'PORT': 6000,
    'SECRET_PASSWORD': secret_password or '',
}
