"""
Script to create a default admin user for development.
Run this after migrations to set up admin access.
"""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.local')
django.setup()

from apps.users.models import User

def create_admin():
    email = 'admin@outfitstylist.com'
    password = 'admin123'
    
    # Check if admin already exists
    if User.objects.filter(email=email).exists():
        print(f'✓ Admin user already exists: {email}')
        return
    
    # Create admin user
    admin = User.objects.create_superuser(
        email=email,
        password=password,
    )
    admin.is_verified = True
    admin.save()
    
    print('=' * 50)
    print('✓ Admin user created successfully!')
    print('=' * 50)
    print(f'Email:    {email}')
    print(f'Password: {password}')
    print('=' * 50)
    print('Access admin panel at: http://localhost:8000/admin/')
    print('=' * 50)

if __name__ == '__main__':
    create_admin()
