from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .database.session import engine, Base, SessionLocal
from .models.job import Job
from .api.v1.routes import auth, jobs, users, applications, saved_jobs

def seed_sample_jobs():
    """Seeds initial sample job postings if database is empty."""
    db = SessionLocal()
    try:
        if db.query(Job).count() == 0:
            sample_jobs = [
                Job(
                    title="Junior Flutter Developer",
                    company_name="TechCorp Solutions",
                    location="Pune, India",
                    job_type="Full-time",
                    salary="₹5,00,000 - ₹8,00,000 / year",
                    description="We are looking for a motivated Junior Flutter Developer to build high-performance mobile applications for Android and iOS. You will collaborate with our backend team to integrate REST APIs and implement modern UI designs.",
                    required_skills="Flutter, Dart, REST API, Git, Material Design",
                ),
                Job(
                    title="Python Backend Engineer",
                    company_name="CloudWave Systems",
                    location="Mumbai, India",
                    job_type="Full-time",
                    salary="₹7,00,000 - ₹11,00,000 / year",
                    description="Join our backend infrastructure team building scalable microservices. You will design PostgreSQL schemas, optimize query performance, and build fast RESTful APIs using Python and FastAPI.",
                    required_skills="Python, FastAPI, PostgreSQL, SQLAlchemy, Docker",
                ),
                Job(
                    title="Mobile App Developer Intern",
                    company_name="AppInnovate Studios",
                    location="Pune / Remote",
                    job_type="Internship",
                    salary="₹25,000 / month",
                    description="Exciting 6-month internship for college freshers to gain hands-on production experience in mobile app development. Mentorship provided by senior developers.",
                    required_skills="Dart, Flutter, Object Oriented Programming, Git",
                ),
                Job(
                    title="Full Stack Software Engineer",
                    company_name="NextGen Technologies",
                    location="Bangalore / Hybrid",
                    job_type="Full-time",
                    salary="₹8,50,000 - ₹13,00,000 / year",
                    description="Seeking a Full Stack Engineer to lead web and mobile product lines. Experience with modern responsive frontend frameworks and relational databases is required.",
                    required_skills="Flutter, React, Python, PostgreSQL, REST APIs",
                ),
                Job(
                    title="Remote Flutter Consultant",
                    company_name="GlobalWorks Inc.",
                    location="Remote",
                    job_type="Remote",
                    salary="₹10,00,000 - ₹15,00,000 / year",
                    description="Fully remote position focusing on cross-platform application architecture, custom widget development, and offline caching solutions.",
                    required_skills="Flutter, Dart, Clean Architecture, State Management, CI/CD",
                ),
                Job(
                    title="Database & Backend Specialist",
                    company_name="DataPeak Analytics",
                    location="Hyderabad, India",
                    job_type="Full-time",
                    salary="₹7,50,000 - ₹10,50,000 / year",
                    description="Manage complex database transactions, index optimization, and API service layer development using PostgreSQL and modern Python frameworks.",
                    required_skills="PostgreSQL, Python, FastAPI, Redis, Database Tuning",
                ),
            ]
            db.add_all(sample_jobs)
            db.commit()
            print("Successfully seeded 6 sample job postings into PostgreSQL!")
    finally:
        db.close()

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: Create tables in PostgreSQL and seed sample jobs
    Base.metadata.create_all(bind=engine)
    seed_sample_jobs()
    yield
    # Shutdown logic if any

app = FastAPI(
    title="JobFinder API",
    description="Professional REST API backend for JobFinder Job Portal App built with FastAPI & PostgreSQL.",
    version="1.0.0",
    lifespan=lifespan,
)

# Configure CORS so Flutter Web, Desktop, and Mobile emulators can access the API
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register API v1 routes
app.include_router(auth.router, prefix="/api/v1")
app.include_router(jobs.router, prefix="/api/v1")
app.include_router(users.router, prefix="/api/v1")
app.include_router(applications.router, prefix="/api/v1")
app.include_router(saved_jobs.router, prefix="/api/v1")

@app.get("/", tags=["Root"])
def root():
    return {
        "status": "online",
        "message": "Welcome to JobFinder API",
        "docs_url": "/docs",
        "version": "1.0.0",
    }
