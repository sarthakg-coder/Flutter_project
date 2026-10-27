from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session, joinedload
from ....database.session import get_db
from ....models.saved_job import SavedJob
from ....models.job import Job
from ....models.user import User
from ....schemas.saved_job import SavedJobCreate, SavedJobResponse
from ...deps import get_current_user

router = APIRouter(prefix="/saved-jobs", tags=["Saved Jobs"])

@router.post("", response_model=SavedJobResponse, status_code=status.HTTP_201_CREATED)
def save_job(
    save_in: SavedJobCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    HTTP POST: Adds a job to candidate's saved wishlist.
    """
    job = db.query(Job).filter(Job.id == save_in.job_id).first()
    if not job:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Job not found.",
        )

    existing = db.query(SavedJob).filter(
        SavedJob.user_id == current_user.id,
        SavedJob.job_id == save_in.job_id,
    ).first()
    if existing:
        return existing

    new_saved = SavedJob(user_id=current_user.id, job_id=save_in.job_id)
    db.add(new_saved)
    db.commit()
    db.refresh(new_saved)
    return new_saved

@router.get("", response_model=List[SavedJobResponse])
def get_saved_jobs(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    HTTP GET: Retrieves all jobs saved by the logged-in candidate.
    """
    saved_list = (
        db.query(SavedJob)
        .options(joinedload(SavedJob.job))
        .filter(SavedJob.user_id == current_user.id)
        .order_by(SavedJob.created_at.desc())
        .all()
    )
    return saved_list

@router.delete("/{job_id}", status_code=status.HTTP_200_OK)
def remove_saved_job(
    job_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    HTTP DELETE: Removes a job from candidate's wishlist.
    """
    saved = db.query(SavedJob).filter(
        SavedJob.user_id == current_user.id,
        SavedJob.job_id == job_id,
    ).first()

    if not saved:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Job is not in your saved list.",
        )

    db.delete(saved)
    db.commit()
    return {"message": "Job removed from saved list."}
