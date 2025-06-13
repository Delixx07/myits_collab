-- Table: Admin
CREATE TABLE Admin (
    ID_Admin CHAR(4) PRIMARY KEY,
    Nama_Admin VARCHAR(50) NOT NULL,
    Email_Admin VARCHAR(50) UNIQUE NOT NULL,
    Password_Admin VARCHAR(50) NOT NULL -- Consider using VARCHAR(255) for hashed passwords
);

-- Table: Dosen (Lecturer)
CREATE TABLE Dosen (
    NIP CHAR(18) PRIMARY KEY,
    Nama_Dosen VARCHAR(50) NOT NULL,
    Email_Dosen VARCHAR(50) UNIQUE NOT NULL,
    Password_Dosen VARCHAR(50) NOT NULL -- Corrected from Password_Mahasiswa
);

-- Table: Mahasiswa (Student)
CREATE TABLE Mahasiswa (
    NRP CHAR(10) PRIMARY KEY,
    Nama_Mahasiswa VARCHAR(50) NOT NULL,
    Email_Mahasiswa VARCHAR(50) UNIQUE NOT NULL,
    Password_Mahasiswa VARCHAR(50) NOT NULL -- Consider using VARCHAR(255) for hashed passwords
);

-- Table: Bidang (Field/Area)
CREATE TABLE Bidang (
    ID_Bidang CHAR(4) PRIMARY KEY,
    Nama_Bidang VARCHAR(100) NOT NULL UNIQUE
);

-- Table: Proyek (Project)
CREATE TABLE Proyek (
    ID_Proyek CHAR(4) PRIMARY KEY,
    Judul VARCHAR(255) NOT NULL,
    Deskripsi LONGTEXT,
    Tgl_Upload DATETIME NOT NULL,
    Availability BOOLEAN NOT NULL,
    Admin_ID_Admin CHAR(4) NOT NULL,
    Dosen_NIP CHAR(18) NOT NULL,
    Bidang_ID_Bidang CHAR(4) NOT NULL, -- Corrected data type to match Bidang.ID_Bidang

    FOREIGN KEY (Admin_ID_Admin) REFERENCES Admin(ID_Admin),
    FOREIGN KEY (Dosen_NIP) REFERENCES Dosen(NIP),
    FOREIGN KEY (Bidang_ID_Bidang) REFERENCES Bidang(ID_Bidang)
);

-- Table: Transksi_Mahasiswa_Proyek (Student_Project_Transaction / Application)
-- Composite Primary Key: (Mahasiswa_NRP, Proyek_ID_Proyek, ID_Pendaftaran) as per ERD
CREATE TABLE Transksi_Mahasiswa_Proyek (
    Mahasiswa_NRP CHAR(10) NOT NULL,
    Proyek_ID_Proyek CHAR(4) NOT NULL,
    ID_Pendaftaran CHAR(4) NOT NULL,
    Status BOOLEAN NOT NULL, -- True for accepted, False for pending/rejected

    PRIMARY KEY (Mahasiswa_NRP, Proyek_ID_Proyek, ID_Pendaftaran), -- Composite PK
    FOREIGN KEY (Mahasiswa_NRP) REFERENCES Mahasiswa(NRP),
    FOREIGN KEY (Proyek_ID_Proyek) REFERENCES Proyek(ID_Proyek)
);

-- Table: Dokumen (Documents)
CREATE TABLE Dokumen (
    ID_Dokumen INT AUTO_INCREMENT PRIMARY KEY, -- Using INT AUTO_INCREMENT for easy unique IDs
    -- Foreign keys to link to the specific application this document belongs to
    Transaksi_Mahasiswa_NRP CHAR(10) NOT NULL,
    Transaksi_Proyek_ID_Proyek CHAR(4) NOT NULL,
    Transaksi_ID_Pendaftaran CHAR(4) NOT NULL,

    Nama_Dokumen VARCHAR(100) NOT NULL, -- e.g., 'CV', 'Surat Lamaran', 'Transkrip Nilai'
    File_Path VARCHAR(255) NOT NULL, -- The path or URL where the file is stored (e.g., '/uploads/cv_123.pdf', 'https://s3.aws.com/bucket/cv_123.pdf')
    Tgl_Upload DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (Transaksi_Mahasiswa_NRP, Transaksi_Proyek_ID_Proyek, Transaksi_ID_Pendaftaran)
        REFERENCES Transksi_Mahasiswa_Proyek(Mahasiswa_NRP, Proyek_ID_Proyek, ID_Pendaftaran)
);



---------------------------------------------------------DUMMY
-- Disable foreign key checks temporarily to avoid insertion order issues,
-- especially useful for complex interdependencies or when loading a dump.
-- Re-enable them afterwards.
SET FOREIGN_KEY_CHECKS = 0;

-- 1. Insert data into Admin table
INSERT INTO Admin (ID_Admin, Nama_Admin, Email_Admin, Password_Admin) VALUES
('AD01', 'Budi Santoso', 'budi.admin@example.com', 'adminpass123'),
('AD02', 'Dewi Lestari', 'dewi.admin@example.com', 'secureadmin');

-- 2. Insert data into Dosen (Lecturer) table
INSERT INTO Dosen (NIP, Nama_Dosen, Email_Dosen, Password_Dosen) VALUES
('DN0012345678901234', 'Prof. Joko Susilo', 'joko.susilo@dosen.com', 'dosenpass'),
('DN0023456789012345', 'Dr. Sari Wijaya', 'sari.wijaya@dosen.com', 'saripass');

-- 3. Insert data into Mahasiswa (Student) table
INSERT INTO Mahasiswa (NRP, Nama_Mahasiswa, Email_Mahasiswa, Password_Mahasiswa) VALUES
('MHS0012345', 'Ahmad Fajar', 'ahmad.fajar@student.com', 'ahmadpass'),
('MHS0023456', 'Siti Aminah', 'siti.aminah@student.com', 'sitipass'),
('MHS0034567', 'Rio Pratama', 'rio.pratama@student.com', 'riopass');

-- 4. Insert data into Bidang (Field/Area) table
INSERT INTO Bidang (ID_Bidang, Nama_Bidang) VALUES
('BD01', 'Information Technology'),
('BD02', 'Computer Science'),
('BD03', 'Data Science');

-- 5. Insert data into Proyek (Project) table
-- Ensure Admin_ID_Admin, Dosen_NIP, and Bidang_ID_Bidang refer to existing IDs
INSERT INTO Proyek (ID_Proyek, Judul, Deskripsi, Tgl_Upload, Availability, Admin_ID_Admin, Dosen_NIP, Bidang_ID_Bidang) VALUES
('PRJ1', 'Pengembangan Aplikasi Web E-commerce', 'Proyek pengembangan aplikasi web untuk platform e-commerce dengan fitur pembayaran terintegrasi.', '2025-05-20 10:00:00', TRUE, 'AD01', 'DN0012345678901234', 'BD01'),
('PRJ2', 'Analisis Sentimen Media Sosial', 'Analisis data dari platform media sosial untuk memahami sentimen publik terhadap topik tertentu.', '2025-05-25 14:30:00', TRUE, 'AD02', 'DN0023456789012345', 'BD03'),
('PRJ3', 'Sistem Rekomendasi Film Berbasis Konten', 'Membangun sistem rekomendasi film menggunakan teknik pemrosesan bahasa alami pada deskripsi film.', '2025-06-01 09:00:00', FALSE, 'AD01', 'DN0023456789012345', 'BD03'),
('PRJ4', 'Aplikasi Mobile Pembelajaran Bahasa', 'Pengembangan aplikasi mobile interaktif untuk membantu pembelajaran bahasa asing.', '2025-06-05 11:00:00', TRUE, 'AD02', 'DN0012345678901234', 'BD01');

-- 6. Insert data into Transksi_Mahasiswa_Proyek (Student Project Transaction / Application) table
-- Ensure Mahasiswa_NRP, Proyek_ID_Proyek, and ID_Pendaftaran are unique for the composite PK
INSERT INTO Transksi_Mahasiswa_Proyek (Mahasiswa_NRP, Proyek_ID_Proyek, ID_Pendaftaran, Status) VALUES
('MHS0012345', 'PRJ1', 'APP1', FALSE), -- Ahmad Fajar applies to PRJ1 (Pending)
('MHS0023456', 'PRJ1', 'APP2', TRUE),  -- Siti Aminah applies to PRJ1 (Accepted)
('MHS0012345', 'PRJ2', 'APP3', FALSE), -- Ahmad Fajar applies to PRJ2 (Pending)
('MHS0034567', 'PRJ2', 'APP4', TRUE),  -- Rio Pratama applies to PRJ2 (Accepted)
('MHS0023456', 'PRJ4', 'APP5', FALSE); -- Siti Aminah applies to PRJ4 (Pending)

-- 7. Insert data into Dokumen (Documents) table
-- Ensure foreign keys point to existing entries in Transksi_Mahasiswa_Proyek
INSERT INTO Dokumen (Transaksi_Mahasiswa_NRP, Transaksi_Proyek_ID_Proyek, Transaksi_ID_Pendaftaran, Nama_Dokumen, File_Path, Tgl_Upload) VALUES
('MHS0012345', 'PRJ1', 'APP1', 'Curriculum Vitae', '/uploads/cv/ahmad_fajar_cv_prj1.pdf', '2025-06-02 10:30:00'),
('MHS0012345', 'PRJ1', 'APP1', 'Motivation Letter', '/uploads/ml/ahmad_fajar_ml_prj1.pdf', '2025-06-02 10:35:00'),
('MHS0023456', 'PRJ1', 'APP2', 'Curriculum Vitae', '/uploads/cv/siti_aminah_cv_prj1.pdf', '2025-06-03 11:00:00'),
('MHS0034567', 'PRJ2', 'APP4', 'Curriculum Vitae', '/uploads/cv/rio_pratama_cv_prj2.pdf', '2025-06-11 14:00:00');

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;