# production_env.py
from env.common_env import common_settings
from env._production_secrets import (
    secret_password,
)

settings = {
    **common_settings,
    'PORT': 80,
    'SECRET_PASSWORD': secret_password or '',
}
