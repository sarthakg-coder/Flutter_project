from datetime import datetime
from typing import Optional
from pydantic import BaseModel
from .job import JobResponse

class ApplicationCreate(BaseModel):
    job_id: int
    cover_letter: Optional[str] = None

class ApplicationResponse(BaseModel):
    id: int
    user_id: int
    job_id: int
    cover_letter: Optional[str] = None
    status: str
    applied_at: Optional[datetime] = None
    job: Optional[JobResponse] = None

    class Config:
        from_attributes = True
