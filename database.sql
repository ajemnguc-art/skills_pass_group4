CREATE DATABASE IF NOT EXISTS skillpass
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE skillpass;

CREATE TABLE IF NOT EXISTS users (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(120) NOT NULL,
  email VARCHAR(190) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('jobseeker', 'employer') NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_users_email (email)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS profiles (
  user_id BIGINT UNSIGNED NOT NULL,
  headline VARCHAR(160) NOT NULL DEFAULT '',
  location VARCHAR(120) NOT NULL DEFAULT '',
  bio TEXT NOT NULL,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id),
  CONSTRAINT fk_profiles_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS skills (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(60) NOT NULL,
  slug VARCHAR(70) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_skills_slug (slug)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS user_skills (
  user_id BIGINT UNSIGNED NOT NULL,
  skill_id BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (user_id, skill_id),
  CONSTRAINT fk_user_skills_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_user_skills_skill FOREIGN KEY (skill_id) REFERENCES skills(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS projects (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  title VARCHAR(160) NOT NULL,
  description TEXT NOT NULL,
  evidence_url VARCHAR(2048) NOT NULL DEFAULT '',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_projects_user (user_id),
  CONSTRAINT fk_projects_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS jobs (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  employer_id BIGINT UNSIGNED NOT NULL,
  title VARCHAR(160) NOT NULL,
  company VARCHAR(160) NOT NULL,
  location VARCHAR(120) NOT NULL,
  work_type ENUM('On-site', 'Hybrid', 'Remote') NOT NULL DEFAULT 'On-site',
  description TEXT NOT NULL,
  status ENUM('open', 'closed') NOT NULL DEFAULT 'open',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_jobs_status_created (status, created_at),
  KEY idx_jobs_employer (employer_id),
  CONSTRAINT fk_jobs_employer FOREIGN KEY (employer_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS job_skills (
  job_id BIGINT UNSIGNED NOT NULL,
  skill_id BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (job_id, skill_id),
  CONSTRAINT fk_job_skills_job FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE,
  CONSTRAINT fk_job_skills_skill FOREIGN KEY (skill_id) REFERENCES skills(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS challenges (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  job_id BIGINT UNSIGNED NOT NULL,
  title VARCHAR(160) NOT NULL,
  instructions TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_challenges_job (job_id),
  CONSTRAINT fk_challenges_job FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS applications (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  job_id BIGINT UNSIGNED NOT NULL,
  jobseeker_id BIGINT UNSIGNED NOT NULL,
  cover_note TEXT NOT NULL,
  status ENUM('submitted', 'reviewing', 'shortlisted', 'declined', 'hired') NOT NULL DEFAULT 'submitted',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_application_jobseeker (job_id, jobseeker_id),
  KEY idx_applications_job_status (job_id, status),
  KEY idx_applications_jobseeker (jobseeker_id),
  CONSTRAINT fk_applications_job FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE,
  CONSTRAINT fk_applications_jobseeker FOREIGN KEY (jobseeker_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS challenge_submissions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  challenge_id BIGINT UNSIGNED NOT NULL,
  jobseeker_id BIGINT UNSIGNED NOT NULL,
  response TEXT NOT NULL,
  evidence_url VARCHAR(2048) NOT NULL DEFAULT '',
  status ENUM('submitted', 'passed', 'needs_work') NOT NULL DEFAULT 'submitted',
  reviewer_note TEXT NOT NULL,
  submitted_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  reviewed_at TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_submission_candidate (challenge_id, jobseeker_id),
  CONSTRAINT fk_submissions_challenge FOREIGN KEY (challenge_id) REFERENCES challenges(id) ON DELETE CASCADE,
  CONSTRAINT fk_submissions_jobseeker FOREIGN KEY (jobseeker_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

INSERT IGNORE INTO users (id, name, email, password_hash, role) VALUES
(1, 'SkillPass Employer', 'employer@skillpass.cm', '$2y$10$E5OF1iKLyHKNTvhkHiMhTOMEcSVQXnZ0riQQgpDzKkRmc67AOdQAa', 'employer'),
(2, 'Amina Nfor', 'amina@skillpass.cm', '$2y$10$E5OF1iKLyHKNTvhkHiMhTOMEcSVQXnZ0riQQgpDzKkRmc67AOdQAa', 'jobseeker'),
(3, 'Joel Tabi', 'joel@skillpass.cm', '$2y$10$E5OF1iKLyHKNTvhkHiMhTOMEcSVQXnZ0riQQgpDzKkRmc67AOdQAa', 'jobseeker');

INSERT IGNORE INTO profiles (user_id, headline, location, bio) VALUES
(1, 'People-first hiring for growing teams', 'Douala', 'Find people who can demonstrate the skills your business needs.'),
(2, 'Junior web developer', 'Douala', 'I build clear, responsive websites and enjoy solving practical problems.'),
(3, 'Digital marketer and content creator', 'Yaounde', 'I help small businesses reach customers through useful content and thoughtful campaigns.');

INSERT IGNORE INTO skills (id, name, slug) VALUES
(1, 'HTML', 'html'),
(2, 'CSS', 'css'),
(3, 'JavaScript', 'javascript'),
(4, 'PHP', 'php'),
(5, 'Customer service', 'customer-service'),
(6, 'Communication', 'communication'),
(7, 'Content writing', 'content-writing'),
(8, 'Social media', 'social-media');

INSERT IGNORE INTO user_skills (user_id, skill_id) VALUES
(2, 1), (2, 2), (2, 3), (2, 4), (2, 6),
(3, 6), (3, 7), (3, 8);

INSERT IGNORE INTO projects (user_id, title, description, evidence_url) VALUES
(2, 'Neighbourhood shop website', 'Designed and built a responsive product catalogue for a local shop.', 'https://example.com/shop-project'),
(3, 'Community market campaign', 'Planned a two-week social media campaign and wrote its posts.', 'https://example.com/market-campaign');

INSERT IGNORE INTO jobs (id, employer_id, title, company, location, work_type, description) VALUES
(1, 1, 'Junior Web Assistant', 'SkillPass Demo Studio', 'Douala', 'Hybrid', 'Help our small team improve accessible web pages, test features, and maintain a simple PHP website. We value practical examples and curiosity.'),
(2, 1, 'Customer Support Associate', 'SkillPass Demo Studio', 'Douala', 'On-site', 'Support customers in person and online, resolve everyday issues, and keep clear service notes.'),
(3, 1, 'Social Media Assistant', 'SkillPass Demo Studio', 'Yaounde', 'Remote', 'Create helpful social posts, support a simple content calendar, and review engagement with the team.');

INSERT IGNORE INTO job_skills (job_id, skill_id) VALUES
(1, 1), (1, 2), (1, 3), (1, 4),
(2, 5), (2, 6),
(3, 6), (3, 7), (3, 8);

INSERT IGNORE INTO challenges (job_id, title, instructions) VALUES
(1, 'Improve a sample product page', 'Share a small page or code sample that presents a product clearly on mobile. Explain one accessibility choice and include a link to your work.'),
(2, 'Respond to a customer scenario', 'Describe how you would help a customer whose order is late. Show how you would listen, explain the next steps, and follow up.'),
(3, 'Plan a short campaign', 'Outline three posts for a local business. Include the intended audience, the message, and one way you would measure whether it worked.');

INSERT IGNORE INTO applications (job_id, jobseeker_id, cover_note, status) VALUES
(1, 2, 'I have built a responsive shop catalogue and would love to bring that hands-on experience to your team.', 'submitted'),
(3, 3, 'I recently planned a campaign for a community market and can share the content plan and results.', 'reviewing');
