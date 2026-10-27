from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field

class JobBase(BaseModel):
    title: str = Field(..., min_length=2, max_length=150)
    company_name: str = Field(..., min_length=2, max_length=120)
    location: str = Field(..., min_length=2, max_length=100)
    job_type: str = Field(..., min_length=2, max_length=50)
    salary: Optional[str] = None
    description: str = Field(..., min_length=10)
    required_skills: Optional[str] = None

class JobCreate(JobBase):
    pass

class JobResponse(JobBase):
    id: int
    created_at: Optional[datetime] = None
    is_saved: Optional[bool] = False

    class Config:
        from_attributes = True
