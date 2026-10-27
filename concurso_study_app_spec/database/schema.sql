-- SQLite schema v1 for Trilha de Aprovação.
-- The application must run this migration transactionally and enable foreign keys
-- on every connection. Never modify an already released migration in place.

PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS contests (
    id TEXT PRIMARY KEY NOT NULL,
    name TEXT NOT NULL CHECK (length(trim(name)) > 0),
    examining_board TEXT,
    exam_date TEXT, -- ISO calendar date YYYY-MM-DD
    status TEXT NOT NULL DEFAULT 'active'
        CHECK (status IN ('active', 'archived')),
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_contests_status_name
    ON contests(status, name COLLATE NOCASE);

CREATE TABLE IF NOT EXISTS subjects (
    id TEXT PRIMARY KEY NOT NULL,
    contest_id TEXT NOT NULL,
    name TEXT NOT NULL CHECK (length(trim(name)) > 0),
    weight REAL CHECK (weight IS NULL OR weight >= 0),
    target_accuracy_pct REAL
        CHECK (target_accuracy_pct IS NULL OR (target_accuracy_pct >= 0 AND target_accuracy_pct <= 100)),
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    UNIQUE (contest_id, name COLLATE NOCASE),
    UNIQUE (id, contest_id),
    FOREIGN KEY (contest_id) REFERENCES contests(id) ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_subjects_contest_order
    ON subjects(contest_id, sort_order, name COLLATE NOCASE);

CREATE TABLE IF NOT EXISTS topics (
    id TEXT PRIMARY KEY NOT NULL,
    subject_id TEXT NOT NULL,
    parent_topic_id TEXT,
    name TEXT NOT NULL CHECK (length(trim(name)) > 0),
    estimated_minutes INTEGER CHECK (estimated_minutes IS NULL OR estimated_minutes >= 0),
    difficulty INTEGER CHECK (difficulty IS NULL OR difficulty BETWEEN 1 AND 5),
    status TEXT NOT NULL DEFAULT 'not_started'
        CHECK (status IN ('not_started', 'in_progress', 'completed', 'needs_review')),
    sort_order INTEGER NOT NULL DEFAULT 0,
    notes TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    UNIQUE (id, subject_id),
    FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE RESTRICT,
    FOREIGN KEY (parent_topic_id, subject_id) REFERENCES topics(id, subject_id) ON DELETE RESTRICT,
    CHECK (parent_topic_id IS NULL OR parent_topic_id <> id)
);

CREATE INDEX IF NOT EXISTS idx_topics_subject_order
    ON topics(subject_id, parent_topic_id, sort_order, name COLLATE NOCASE);
CREATE INDEX IF NOT EXISTS idx_topics_status
    ON topics(status, subject_id);

CREATE TABLE IF NOT EXISTS study_sessions (
    id TEXT PRIMARY KEY NOT NULL,
    contest_id TEXT NOT NULL,
    subject_id TEXT NOT NULL,
    topic_id TEXT,
    session_type TEXT NOT NULL DEFAULT 'study'
        CHECK (session_type IN ('study', 'review', 'questions', 'mock_exam')),
    status TEXT NOT NULL DEFAULT 'running'
        CHECK (status IN ('running', 'paused', 'completed', 'interrupted')),
    started_at TEXT NOT NULL,
    active_since TEXT, -- non-null only while the timer is actively running
    ended_at TEXT,
    duration_seconds INTEGER NOT NULL DEFAULT 0 CHECK (duration_seconds >= 0),
    notes TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    FOREIGN KEY (contest_id) REFERENCES contests(id) ON DELETE RESTRICT,
    FOREIGN KEY (subject_id, contest_id) REFERENCES subjects(id, contest_id) ON DELETE RESTRICT,
    FOREIGN KEY (topic_id, subject_id) REFERENCES topics(id, subject_id) ON DELETE RESTRICT,
    CHECK (ended_at IS NULL OR ended_at >= started_at),
    CHECK (status <> 'completed' OR ended_at IS NOT NULL),
    CHECK ((status = 'running' AND active_since IS NOT NULL) OR
           (status <> 'running' AND active_since IS NULL))
);

CREATE INDEX IF NOT EXISTS idx_sessions_contest_started
    ON study_sessions(contest_id, started_at DESC);
CREATE INDEX IF NOT EXISTS idx_sessions_subject_started
    ON study_sessions(subject_id, started_at DESC);
CREATE INDEX IF NOT EXISTS idx_sessions_status_started
    ON study_sessions(status, started_at DESC);

CREATE TABLE IF NOT EXISTS daily_goals (
    id TEXT PRIMARY KEY NOT NULL,
    contest_id TEXT NOT NULL,
    goal_date TEXT NOT NULL, -- local calendar date YYYY-MM-DD
    target_minutes INTEGER CHECK (target_minutes IS NULL OR target_minutes >= 0),
    target_questions INTEGER CHECK (target_questions IS NULL OR target_questions >= 0),
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    UNIQUE (contest_id, goal_date),
    FOREIGN KEY (contest_id) REFERENCES contests(id) ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_daily_goals_date
    ON daily_goals(goal_date, contest_id);

CREATE TABLE IF NOT EXISTS study_plan_items (
    id TEXT PRIMARY KEY NOT NULL,
    contest_id TEXT NOT NULL,
    subject_id TEXT NOT NULL,
    topic_id TEXT,
    planned_date TEXT NOT NULL, -- local calendar date YYYY-MM-DD
    planned_minutes INTEGER NOT NULL DEFAULT 0 CHECK (planned_minutes >= 0),
    priority INTEGER NOT NULL DEFAULT 3 CHECK (priority BETWEEN 1 AND 5),
    status TEXT NOT NULL DEFAULT 'planned'
        CHECK (status IN ('planned', 'completed', 'skipped', 'carried_over')),
    session_id TEXT,
    notes TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    FOREIGN KEY (contest_id) REFERENCES contests(id) ON DELETE RESTRICT,
    FOREIGN KEY (subject_id, contest_id) REFERENCES subjects(id, contest_id) ON DELETE RESTRICT,
    FOREIGN KEY (topic_id, subject_id) REFERENCES topics(id, subject_id) ON DELETE RESTRICT,
    FOREIGN KEY (session_id) REFERENCES study_sessions(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_plan_date_status
    ON study_plan_items(contest_id, planned_date, status, priority DESC);
CREATE INDEX IF NOT EXISTS idx_plan_subject_date
    ON study_plan_items(subject_id, planned_date);

CREATE TABLE IF NOT EXISTS question_attempts (
    id TEXT PRIMARY KEY NOT NULL,
    contest_id TEXT NOT NULL,
    subject_id TEXT NOT NULL,
    topic_id TEXT,
    source TEXT,
    examining_board TEXT,
    question_ref TEXT,
    answered_at TEXT NOT NULL,
    is_correct INTEGER NOT NULL CHECK (is_correct IN (0, 1)),
    time_seconds INTEGER CHECK (time_seconds IS NULL OR time_seconds >= 0),
    difficulty INTEGER CHECK (difficulty IS NULL OR difficulty BETWEEN 1 AND 5),
    error_category TEXT,
    notes TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    FOREIGN KEY (contest_id) REFERENCES contests(id) ON DELETE RESTRICT,
    FOREIGN KEY (subject_id, contest_id) REFERENCES subjects(id, contest_id) ON DELETE RESTRICT,
    FOREIGN KEY (topic_id, subject_id) REFERENCES topics(id, subject_id) ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_attempts_contest_answered
    ON question_attempts(contest_id, answered_at DESC);
CREATE INDEX IF NOT EXISTS idx_attempts_subject_answered
    ON question_attempts(subject_id, answered_at DESC);
CREATE INDEX IF NOT EXISTS idx_attempts_topic_answered
    ON question_attempts(topic_id, answered_at DESC);
CREATE INDEX IF NOT EXISTS idx_attempts_result
    ON question_attempts(is_correct, answered_at DESC);

CREATE TABLE IF NOT EXISTS review_items (
    id TEXT PRIMARY KEY NOT NULL,
    contest_id TEXT NOT NULL,
    subject_id TEXT NOT NULL,
    topic_id TEXT,
    source_session_id TEXT,
    source_attempt_id TEXT,
    due_at TEXT NOT NULL,
    last_reviewed_at TEXT,
    status TEXT NOT NULL DEFAULT 'scheduled'
        CHECK (status IN ('scheduled', 'completed', 'skipped', 'cancelled')),
    interval_days INTEGER NOT NULL DEFAULT 1 CHECK (interval_days >= 0),
    ease_factor REAL NOT NULL DEFAULT 2.5 CHECK (ease_factor >= 1.3),
    repetition_count INTEGER NOT NULL DEFAULT 0 CHECK (repetition_count >= 0),
    notes TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    FOREIGN KEY (contest_id) REFERENCES contests(id) ON DELETE RESTRICT,
    FOREIGN KEY (subject_id, contest_id) REFERENCES subjects(id, contest_id) ON DELETE RESTRICT,
    FOREIGN KEY (topic_id, subject_id) REFERENCES topics(id, subject_id) ON DELETE RESTRICT,
    FOREIGN KEY (source_session_id) REFERENCES study_sessions(id) ON DELETE RESTRICT,
    FOREIGN KEY (source_attempt_id) REFERENCES question_attempts(id) ON DELETE RESTRICT,
    CHECK (topic_id IS NOT NULL OR source_attempt_id IS NOT NULL OR source_session_id IS NOT NULL)
);

CREATE INDEX IF NOT EXISTS idx_reviews_due_status
    ON review_items(status, due_at, contest_id);
CREATE INDEX IF NOT EXISTS idx_reviews_subject_due
    ON review_items(subject_id, due_at);

CREATE TABLE IF NOT EXISTS notes (
    id TEXT PRIMARY KEY NOT NULL,
    contest_id TEXT,
    subject_id TEXT,
    topic_id TEXT,
    title TEXT NOT NULL DEFAULT 'Anotação' CHECK (length(trim(title)) > 0),
    content TEXT NOT NULL,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    FOREIGN KEY (contest_id) REFERENCES contests(id) ON DELETE RESTRICT,
    FOREIGN KEY (subject_id, contest_id) REFERENCES subjects(id, contest_id) ON DELETE RESTRICT,
    FOREIGN KEY (topic_id, subject_id) REFERENCES topics(id, subject_id) ON DELETE RESTRICT,
    CHECK (subject_id IS NULL OR contest_id IS NOT NULL),
    CHECK (topic_id IS NULL OR subject_id IS NOT NULL)
);

CREATE INDEX IF NOT EXISTS idx_notes_updated
    ON notes(updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_notes_topic_updated
    ON notes(topic_id, updated_at DESC);

-- Use PRAGMA user_version in the migration runner, not as the only migration record.
PRAGMA user_version = 1;
