# D:\Assignment\SEM 4\MBD\myits-collab\backend\app\services\project_service.py

from sqlalchemy.orm import Session, joinedload
from app.models import projects as project_model
from app.schemas import projects as project_schema
from typing import List, Optional
import datetime
import uuid

# --- Bidang Operations ---

def get_bidang_by_id(db: Session, bidang_id: str):
    """Fetches a Bidang by ID."""
    return db.query(project_model.Bidang).filter(project_model.Bidang.ID_Bidang == bidang_id).first()

def get_all_bidang(db: Session) -> List[project_model.Bidang]:
    """Fetches all Bidang entries."""
    return db.query(project_model.Bidang).all()

def create_bidang(db: Session, bidang: project_schema.BidangCreate):
    """Creates a new Bidang in the database."""
    db_bidang = project_model.Bidang(
        ID_Bidang=bidang.id_bidang,
        Nama_Bidang=bidang.nama_bidang
    )
    db.add(db_bidang)
    db.commit()
    db.refresh(db_bidang)
    return db_bidang

# --- Proyek Operations ---

def get_project_by_id(db: Session, project_id: str):
    """Fetches a project by ID."""
    # Use joinedload to eager-load related data (admin, dosen, bidang)
    # This avoids N+1 query problem when you access relationships
    return db.query(project_model.Proyek).options(
        joinedload(project_model.Proyek.admin),
        joinedload(project_model.Proyek.dosen),
        # joinedload(project_model.Proyek.bidang)
    ).filter(project_model.Proyek.ID_Proyek == project_id).first()

def get_all_projects(
    db: Session,
    skip: int = 0,
    limit: int = 100,
    available_only: Optional[bool] = None,
    dosen_nip_filter: Optional[str] = None, # <--- ADD THIS ARGUMENT
    admin_id_filter: Optional[str] = None  # <--- ADD THIS ARGUMENT
) -> List[project_model.Proyek]:
    """Fetches a list of projects with optional filtering."""
    query = db.query(project_model.Proyek).options(
        joinedload(project_model.Proyek.admin),
        joinedload(project_model.Proyek.dosen),
        # joinedload(project_model.Proyek.bidang)
    )
    if available_only is not None:
        query = query.filter(project_model.Proyek.Availability == available_only)

    if dosen_nip_filter: # <--- APPLY FILTER IF PROVIDED
        query = query.filter(project_model.Proyek.Dosen_NIP == dosen_nip_filter)
    if admin_id_filter: # <--- APPLY FILTER IF PROVIDED
        query = query.filter(project_model.Proyek.Admin_ID_Admin == admin_id_filter)

    return query.offset(skip).limit(limit).all()

def create_project(db: Session, project: project_schema.ProyekCreate, admin_id: Optional[str] = None, dosen_nip: Optional[str] = None):
    """Creates a new project in the database."""

    # Generate a unique ID_Proyek (4 characters)
    # Loop to ensure uniqueness, though highly unlikely to collide with 4 hex chars from UUID
    while True:
        new_id_proyek = str(uuid.uuid4().hex)[:4].upper() # e.g., 'A1B2'
        # Check if this ID already exists in the database
        existing_project = db.query(project_model.Proyek).filter(
            project_model.Proyek.ID_Proyek == new_id_proyek
        ).first()
        if not existing_project:
            break # Found a unique ID

    db_project = project_model.Proyek(
        ID_Proyek=new_id_proyek, # <--- ASSIGN THE GENERATED ID HERE
        Judul=project.judul,
        Deskripsi=project.deskripsi,
        Availability=project.availability,
        Admin_ID_Admin=admin_id,
        Dosen_NIP=dosen_nip,
        Nama_Bidang=project.nama_bidang,
        Tgl_Upload=datetime.datetime.now()
    )
    db.add(db_project)
    db.commit()
    db.refresh(db_project)
    return db_project

def update_project(db: Session, db_project: project_model.Proyek, project_update: project_schema.ProyekUpdate):
    """Updates an existing project."""
    update_data = project_update.model_dump(exclude_unset=True) # Exclude fields not set in the update request

    for key, value in update_data.items():
        if key == 'bidang_id': # Special handling for FK if you want to update via alias
            setattr(db_project, 'Bidang_ID_Bidang', value)
        else:
            setattr(db_project, key, value) # Directly set attributes from Pydantic schema

    db.add(db_project)
    db.commit()
    db.refresh(db_project)
    return db_project

def delete_project(db: Session, project_id: str):
    """Deletes a project."""
    db_project = db.query(project_model.Proyek).filter(project_model.Proyek.ID_Proyek == project_id).first()
    if db_project:
        db.delete(db_project)
        db.commit()
        return True
    return False

# You can add more functions here for updating, deleting, filtering, etc.