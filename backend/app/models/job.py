from datetime import datetime, timezone
from sqlalchemy import Column, Integer, String, Text, DateTime
from sqlalchemy.orm import relationship
from ..database.session import Base

class Job(Base):
    __tablename__ = "jobs"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(150), nullable=False, index=True)
    company_name = Column(String(120), nullable=False, index=True)
    location = Column(String(100), nullable=False)
    job_type = Column(String(50), nullable=False, default="Full-time") # Full-time, Part-time, Remote, Internship
    salary = Column(String(100), nullable=True)
    description = Column(Text, nullable=False)
    required_skills = Column(String(255), nullable=True) # e.g. "Flutter, Dart, REST API"
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))

    # Relationships
    applications = relationship("Application", back_populates="job", cascade="all, delete-orphan")
    saved_by = relationship("SavedJob", back_populates="job", cascade="all, delete-orphan")
