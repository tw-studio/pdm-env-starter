# load_env.py
import os

PDM_ENV = os.environ.get('PDM_ENV', 'development')

if PDM_ENV == 'development':
    from env.development_env import settings
elif PDM_ENV == 'production':
    from env.production_env import settings
else:
    raise ValueError("Invalid PDM_ENV setting")

for key, value in settings.items():
    print(f'export {key}="{value}"')
    