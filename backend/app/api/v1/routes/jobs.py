from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session
from sqlalchemy import or_
from ....database.session import get_db
from ....models.job import Job
from ....models.saved_job import SavedJob
from ....models.user import User
from ....schemas.job import JobResponse
from ...deps import get_current_user_optional

router = APIRouter(prefix="/jobs", tags=["Jobs"])

@router.get("", response_model=List[JobResponse])
def get_jobs(
    search: Optional[str] = Query(None, description="Search by title or company name"),
    job_type: Optional[str] = Query(None, description="Filter by job type"),
    db: Session = Depends(get_db),
    current_user: Optional[User] = Depends(get_current_user_optional),
):
    """
    Fetches job listings with optional search and job type filters.
    If authenticated, indicates whether each job is in user's saved wishlist.
    """
    query = db.query(Job)

    if search and search.strip():
        term = f"%{search.strip()}%"
        query = query.filter(
            or_(
                Job.title.ilike(term),
                Job.company_name.ilike(term),
                Job.location.ilike(term),
                Job.required_skills.ilike(term),
            )
        )

    if job_type and job_type.strip() and job_type.lower() != "all":
        query = query.filter(Job.job_type.ilike(f"%{job_type.strip()}%"))

    jobs = query.order_by(Job.id.desc()).all()

    # Determine which jobs the current user has saved
    saved_job_ids = set()
    if current_user:
        saved_records = db.query(SavedJob.job_id).filter(SavedJob.user_id == current_user.id).all()
        saved_job_ids = {r[0] for r in saved_records}

    result = []
    for j in jobs:
        job_data = JobResponse.model_validate(j)
        job_data.is_saved = j.id in saved_job_ids
        result.append(job_data)

    return result

@router.get("/{job_id}", response_model=JobResponse)
def get_job_by_id(
    job_id: int,
    db: Session = Depends(get_db),
    current_user: Optional[User] = Depends(get_current_user_optional),
):
    """
    Fetches details of a specific job by its unique ID.
    """
    job = db.query(Job).filter(Job.id == job_id).first()
    if not job:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Job with ID {job_id} was not found.",
        )

    is_saved = False
    if current_user:
        saved = db.query(SavedJob).filter(
            SavedJob.user_id == current_user.id,
            SavedJob.job_id == job_id,
        ).first()
        is_saved = saved is not None

    job_data = JobResponse.model_validate(job)
    job_data.is_saved = is_saved
    return job_data
