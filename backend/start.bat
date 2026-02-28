@echo off
echo ========================================
echo  AI Outfit Stylist - Backend Server
echo ========================================
echo.

cd /d %~dp0

:: Set Django settings
set DJANGO_SETTINGS_MODULE=config.settings.local

:: Install dependencies
echo [1/3] Installing dependencies...
pip install -r requirements.txt
if errorlevel 1 (
    echo ERROR: Failed to install dependencies
    pause
    exit /b 1
)

:: Run migrations
echo.
echo [2/3] Running database migrations...
python manage.py migrate
if errorlevel 1 (
    echo ERROR: Failed to run migrations
    pause
    exit /b 1
)

:: Start server
echo.
echo [3/3] Starting development server on http://0.0.0.0:8000
echo.
echo Press Ctrl+C to stop the server
echo ========================================
python manage.py runserver 0.0.0.0:8000
