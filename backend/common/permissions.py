from rest_framework.permissions import BasePermission


class IsOwner(BasePermission):
    """Only allow owners of an object to access it."""

    def has_object_permission(self, request, view, obj):
        if hasattr(obj, 'user_id'):
            return obj.user_id == request.user.id
        if hasattr(obj, 'user'):
            return obj.user == request.user
        return False
