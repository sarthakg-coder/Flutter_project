from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker
from ..core.config import settings

# Create SQLAlchemy engine connected to PostgreSQL
engine = create_engine(
    settings.DATABASE_URL,
    pool_pre_ping=True,
    pool_size=10,
    max_overflow=20,
)

# SessionLocal class will generate new database sessions
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Declarative Base for models
Base = declarative_base()

def get_db():
    """
    FastAPI dependency that provides a transactional database session per request.
    Closes the session cleanly after the request is finished.
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
