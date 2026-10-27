from datetime import datetime
from typing import Optional
from pydantic import BaseModel
from .job import JobResponse

class SavedJobCreate(BaseModel):
    job_id: int

class SavedJobResponse(BaseModel):
    id: int
    user_id: int
    job_id: int
    created_at: Optional[datetime] = None
    job: Optional[JobResponse] = None

    class Config:
        from_attributes = True
