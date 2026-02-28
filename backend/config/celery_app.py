import os
from celery import Celery
from celery.schedules import crontab

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.local')

app = Celery('outfit_stylist')
app.config_from_object('django.conf:settings', namespace='CELERY')
app.autodiscover_tasks()

# Celery Beat schedule for daily recommendation generation
app.conf.beat_schedule = {
    'generate-daily-recommendations': {
        'task': 'apps.outfits.tasks.generate_all_daily_recommendations',
        'schedule': crontab(hour=6, minute=0),  # Every day at 6 AM UTC
    },
}
