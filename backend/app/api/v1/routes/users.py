from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from ....database.session import get_db
from ....models.user import User
from ....schemas.user import UserUpdate, UserResponse
from ...deps import get_current_user

router = APIRouter(prefix="/users", tags=["Users"])

@router.get("/me", response_model=UserResponse)
def get_user_profile(current_user: User = Depends(get_current_user)):
    return current_user

@router.put("/me", response_model=UserResponse)
def update_user_profile(
    user_update: UserUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if user_update.full_name is not None and user_update.full_name.strip():
        current_user.full_name = user_update.full_name.strip()

    if user_update.phone is not None:
        current_user.phone = user_update.phone.strip() if user_update.phone.strip() else None

    if user_update.location is not None:
        current_user.location = user_update.location.strip() if user_update.location.strip() else None

    db.add(current_user)
    db.commit()
    db.refresh(current_user)

    return current_user
