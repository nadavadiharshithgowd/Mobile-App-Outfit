# Django Admin Setup Guide

## Quick Setup (Automatic)

### Option 1: Use start_with_admin.bat (Windows - Easiest)

```bash
cd backend
start_with_admin.bat
```

This will:
1. Install dependencies
2. Run migrations
3. Create admin user automatically
4. Start the server

**Default Admin Credentials:**
- Email: `admin@outfitstylist.com`
- Password: `admin123`

Access admin at: `http://localhost:8000/admin/`

### Option 2: Run create_admin.py script

```bash
cd backend
python create_admin.py
```

This creates the same default admin user.

## Manual Setup (Custom Credentials)

If you want to create an admin with custom credentials:

```bash
cd backend
python manage.py createsuperuser
```

Follow the prompts:
- Email: (enter your email)
- Password: (enter your password)
- Password (again): (confirm password)

## Accessing Django Admin

1. Start the backend server:
   ```bash
   python manage.py runserver
   ```

2. Open your browser and go to:
   ```
   http://localhost:8000/admin/
   ```

3. Login with your admin credentials

## What You Can Do in Admin Panel

### User Management
- View all registered users
- Edit user details
- Verify user accounts
- Manage user permissions

### Wardrobe Management
- View all wardrobe items
- See item metadata (category, brand, season)
- Check processing status
- View image URLs
- Delete items

### Outfit Management
- View all created outfits
- See outfit compositions
- Check compatibility scores
- Manage favorites

### Try-On Management
- View try-on requests
- Check processing status
- See result images
- Monitor errors

## Admin Features

### Search and Filters
- Search users by email
- Filter wardrobe items by category, season, status
- Filter outfits by occasion, favorite status
- Filter try-ons by status

### Bulk Actions
- Delete multiple items at once
- Export data to CSV
- Bulk update fields

### Data Inspection
- View detailed object information
- See related objects
- Check timestamps
- Inspect JSON fields

## Security Notes

⚠️ **Important for Production:**

1. **Change Default Password**: The default admin password (`admin123`) is for development only
2. **Use Strong Passwords**: Create a strong, unique password for production
3. **Limit Admin Access**: Only give admin access to trusted users
4. **Enable 2FA**: Consider adding two-factor authentication
5. **Monitor Admin Actions**: Django logs all admin actions

## Troubleshooting

### Can't Login to Admin

**Issue**: "Please enter the correct email and password"

**Solutions:**
1. Verify you're using the correct credentials
2. Check if user exists:
   ```bash
   python manage.py shell
   >>> from apps.users.models import User
   >>> User.objects.filter(email='admin@outfitstylist.com').exists()
   ```
3. Reset password:
   ```bash
   python manage.py changepassword admin@outfitstylist.com
   ```

### Admin Page Not Loading

**Issue**: 404 error on `/admin/`

**Solutions:**
1. Ensure server is running
2. Check URL is correct: `http://localhost:8000/admin/` (with trailing slash)
3. Verify `django.contrib.admin` is in INSTALLED_APPS

### Static Files Not Loading

**Issue**: Admin page has no styling

**Solutions:**
```bash
python manage.py collectstatic --noinput
```

## Creating Additional Admin Users

### Via Django Shell

```bash
python manage.py shell
```

```python
from apps.users.models import User

# Create admin user
admin = User.objects.create_superuser(
    email='another@admin.com',
    password='securepassword123'
)
admin.is_verified = True
admin.save()
```

### Via Management Command

```bash
python manage.py createsuperuser --email another@admin.com
```

## Admin Customization

The admin interface is already customized in each app's `admin.py` file:

- **apps/users/admin.py** - User management
- **apps/wardrobe/admin.py** - Wardrobe items
- **apps/outfits/admin.py** - Outfits and recommendations
- **apps/tryon/admin.py** - Virtual try-on results

You can further customize by editing these files.

## Useful Admin Commands

### View All Users
```bash
python manage.py shell
>>> from apps.users.models import User
>>> User.objects.all()
```

### Make User Admin
```bash
python manage.py shell
>>> from apps.users.models import User
>>> user = User.objects.get(email='user@example.com')
>>> user.is_staff = True
>>> user.is_superuser = True
>>> user.save()
```

### Remove Admin Access
```bash
python manage.py shell
>>> from apps.users.models import User
>>> user = User.objects.get(email='user@example.com')
>>> user.is_staff = False
>>> user.is_superuser = False
>>> user.save()
```

## Production Considerations

For production deployments:

1. **Use Environment Variables** for admin credentials
2. **Enable HTTPS** for admin access
3. **Restrict Admin URL** - Change from `/admin/` to something less obvious
4. **IP Whitelisting** - Limit admin access to specific IPs
5. **Regular Backups** - Backup database before making bulk changes
6. **Audit Logs** - Monitor admin actions

Example production settings:

```python
# config/settings/production.py

# Change admin URL
ADMIN_URL = env('ADMIN_URL', default='secret-admin-panel/')

# Restrict admin access
ALLOWED_ADMIN_IPS = env.list('ALLOWED_ADMIN_IPS', default=[])
```

---

**You're all set!** Access the admin panel and start managing your outfit stylist platform! 🎉
