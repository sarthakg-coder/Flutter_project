from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session, joinedload
from ....database.session import get_db
from ....models.application import Application
from ....models.job import Job
from ....models.user import User
from ....schemas.application import ApplicationCreate, ApplicationResponse
from ...deps import get_current_user

router = APIRouter(prefix="/applications", tags=["Applications"])

@router.post("", response_model=ApplicationResponse, status_code=status.HTTP_201_CREATED)
def apply_for_job(
    app_in: ApplicationCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    HTTP POST: Candidate submits an application for a job.
    Enforces uniqueness: Candidate cannot apply to the same job twice.
    """
    # 1. Verify job exists
    job = db.query(Job).filter(Job.id == app_in.job_id).first()
    if not job:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="The job you are applying for does not exist.",
        )

    # 2. Check for duplicate application
    existing_app = db.query(Application).filter(
        Application.user_id == current_user.id,
        Application.job_id == app_in.job_id,
    ).first()
    if existing_app:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="You have already applied for this job.",
        )

    # 3. Create application
    new_app = Application(
        user_id=current_user.id,
        job_id=app_in.job_id,
        cover_letter=app_in.cover_letter.strip() if app_in.cover_letter else None,
        status="Applied",
    )
    db.add(new_app)
    db.commit()
    db.refresh(new_app)

    return new_app

@router.get("", response_model=List[ApplicationResponse])
def get_my_applications(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    HTTP GET: Retrieves all applications submitted by the logged-in candidate.
    Includes the associated job details.
    """
    applications = (
        db.query(Application)
        .options(joinedload(Application.job))
        .filter(Application.user_id == current_user.id)
        .order_by(Application.applied_at.desc())
        .all()
    )
    return applications

@router.delete("/{application_id}", status_code=status.HTTP_200_OK)
def withdraw_application(
    application_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    HTTP DELETE: Candidate withdraws their submitted application.
    """
    app_record = db.query(Application).filter(
        Application.id == application_id,
        Application.user_id == current_user.id,
    ).first()

    if not app_record:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Application not found or you are not authorized to withdraw it.",
        )

    db.delete(app_record)
    db.commit()
    return {"message": "Application withdrawn successfully."}
