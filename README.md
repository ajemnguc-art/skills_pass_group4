# SkillPass

SkillPass is a PHP, HTML, CSS, and JavaScript skills-first hiring demo. Jobseekers build profiles with skills and project evidence, apply for openings, submit practical challenges, and track application updates. Employers post roles, compare applicants against job-related evidence, review challenges, and shortlist candidates.

## Run with XAMPP

1. Start **Apache** and **MySQL** in the XAMPP Control Panel.
2. Open phpMyAdmin at `http://localhost/phpmyadmin`.
3. Import [`database.sql`](./database.sql). It creates the `skillpass` database, tables, and sample records. It uses `IF NOT EXISTS` and `INSERT IGNORE`, so importing it again will not drop existing tables.
4. Open `http://localhost/GROUP%203%20PROJECT/` in your browser.
5. If your MySQL settings differ from XAMPP's defaults, edit the connection values at the top of [`config.php`](./config.php), or set `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, and `DB_PASSWORD` in the PHP environment.

## Demo accounts

All demo accounts use the password `Demo123!`.

| Role | Email |
| --- | --- |
| Employer | `employer@skillpass.cm` |
| Jobseeker | `amina@skillpass.cm` |
| Jobseeker | `joel@skillpass.cm` |

You can also register new employer or jobseeker accounts from the sign-in screen.

The site root is the public homepage and explains the skills-first flow before account creation. Its floating WhatsApp button opens a chat with SkillPass at `+237 672 828 084`.

## Matching and privacy

Applicants are ordered by a transparent role-fit score: required-skill overlap contributes up to 70 points, project evidence up to 20, and the practical challenge up to 10. The score is a comparison aid, not an automatic hiring decision. It does not use personal characteristics. Candidate email addresses are only shown to the employer after shortlisting; before that, candidate names are abbreviated.

Skill tags are self-reported. Employers review work samples and challenge submissions as separate evidence and record a pass or feedback. This demo stores passwords as PHP password hashes, uses prepared database statements, and protects form submissions with CSRF tokens.
