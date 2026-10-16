-- Azoz Software database schema
-- MySQL/MariaDB, InnoDB, utf8mb4

-- Import this file after selecting the database created by the hosting provider.
-- Example: mariadb -u USER -p DATABASE_NAME < schema.sql

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS deliveries, notifications, financial_transactions, files, messages, conversation_members, conversations, task_reviews, tasks, project_members, projects, quotation_decisions, quotations, project_requests, currencies, audit_logs, login_attempts, developer_invitations, password_resets, email_verifications, users;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE users (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(160) NOT NULL,
  email VARCHAR(190) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('admin','client','developer') NOT NULL DEFAULT 'client',
  status ENUM('pending_verification','active','suspended') NOT NULL DEFAULT 'pending_verification',
  email_verified_at DATETIME NULL,
  profile_image VARCHAR(255) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  last_login_at DATETIME NULL,
  INDEX idx_users_role_status (role, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE email_verifications (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  token_hash CHAR(64) NOT NULL UNIQUE,
  expires_at DATETIME NOT NULL,
  used_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_email_verifications_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_email_verifications_expiry (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE password_resets (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  token_hash CHAR(64) NOT NULL UNIQUE,
  expires_at DATETIME NOT NULL,
  used_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_password_resets_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_password_resets_expiry (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE developer_invitations (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(190) NOT NULL,
  token_hash CHAR(64) NOT NULL UNIQUE,
  invited_by BIGINT UNSIGNED NOT NULL,
  status ENUM('pending','accepted','expired','revoked') NOT NULL DEFAULT 'pending',
  expires_at DATETIME NOT NULL,
  accepted_by BIGINT UNSIGNED NULL,
  accepted_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_invitations_inviter FOREIGN KEY (invited_by) REFERENCES users(id),
  CONSTRAINT fk_invitations_acceptor FOREIGN KEY (accepted_by) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_invitations_email_status (email, status),
  INDEX idx_invitations_expiry (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE login_attempts (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  email_normalized VARCHAR(190) NOT NULL,
  ip_hash CHAR(64) NULL,
  success TINYINT(1) NOT NULL DEFAULT 0,
  attempted_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_login_attempts_email_time (email_normalized, attempted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE audit_logs (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  actor_user_id BIGINT UNSIGNED NULL,
  action VARCHAR(120) NOT NULL,
  entity_type VARCHAR(80) NULL,
  entity_id BIGINT UNSIGNED NULL,
  details_json JSON NULL,
  ip_hash CHAR(64) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_audit_actor FOREIGN KEY (actor_user_id) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_audit_action_time (action, created_at),
  INDEX idx_audit_entity (entity_type, entity_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE currencies (
  id SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  code CHAR(3) NOT NULL UNIQUE,
  name VARCHAR(80) NOT NULL,
  symbol VARCHAR(10) NOT NULL,
  decimal_places TINYINT UNSIGNED NOT NULL DEFAULT 2,
  is_active TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE project_requests (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  client_id BIGINT UNSIGNED NOT NULL,
  title VARCHAR(200) NOT NULL,
  description TEXT NOT NULL,
  service_type VARCHAR(100) NOT NULL,
  budget_amount DECIMAL(19,4) NULL,
  currency_id SMALLINT UNSIGNED NULL,
  expected_deadline DATE NULL,
  status ENUM('new','reviewing','waiting_info','qualified','rejected','cancelled') NOT NULL DEFAULT 'new',
  admin_notes TEXT NULL,
  rejection_reason TEXT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_requests_client FOREIGN KEY (client_id) REFERENCES users(id),
  CONSTRAINT fk_requests_currency FOREIGN KEY (currency_id) REFERENCES currencies(id),
  INDEX idx_requests_client_status (client_id, status),
  INDEX idx_requests_status_date (status, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE quotations (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  request_id BIGINT UNSIGNED NOT NULL,
  version_number INT UNSIGNED NOT NULL,
  created_by BIGINT UNSIGNED NOT NULL,
  scope_description TEXT NOT NULL,
  total_amount DECIMAL(19,4) NOT NULL,
  currency_id SMALLINT UNSIGNED NOT NULL,
  estimated_duration VARCHAR(120) NOT NULL,
  payment_terms TEXT NULL,
  delivery_terms TEXT NULL,
  status ENUM('draft','sent','accepted','rejected','expired','superseded') NOT NULL DEFAULT 'draft',
  sent_at DATETIME NULL,
  expires_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT uq_quotation_version UNIQUE (request_id, version_number),
  CONSTRAINT fk_quotations_request FOREIGN KEY (request_id) REFERENCES project_requests(id),
  CONSTRAINT fk_quotations_creator FOREIGN KEY (created_by) REFERENCES users(id),
  CONSTRAINT fk_quotations_currency FOREIGN KEY (currency_id) REFERENCES currencies(id),
  INDEX idx_quotations_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE quotation_decisions (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  quotation_id BIGINT UNSIGNED NOT NULL,
  client_id BIGINT UNSIGNED NOT NULL,
  decision ENUM('accepted','rejected') NOT NULL,
  decision_note TEXT NULL,
  decided_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_decisions_quotation FOREIGN KEY (quotation_id) REFERENCES quotations(id),
  CONSTRAINT fk_decisions_client FOREIGN KEY (client_id) REFERENCES users(id),
  INDEX idx_decisions_client (client_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE projects (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  request_id BIGINT UNSIGNED NOT NULL,
  quotation_id BIGINT UNSIGNED NOT NULL UNIQUE,
  client_id BIGINT UNSIGNED NOT NULL,
  name VARCHAR(200) NOT NULL,
  description TEXT NOT NULL,
  status ENUM('not_started','in_progress','paused','completed','cancelled') NOT NULL DEFAULT 'not_started',
  start_date DATE NULL,
  expected_end_date DATE NULL,
  completed_at DATETIME NULL,
  created_by BIGINT UNSIGNED NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_projects_request FOREIGN KEY (request_id) REFERENCES project_requests(id),
  CONSTRAINT fk_projects_quotation FOREIGN KEY (quotation_id) REFERENCES quotations(id),
  CONSTRAINT fk_projects_client FOREIGN KEY (client_id) REFERENCES users(id),
  CONSTRAINT fk_projects_creator FOREIGN KEY (created_by) REFERENCES users(id),
  INDEX idx_projects_client_status (client_id, status),
  INDEX idx_projects_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE project_members (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  project_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  assigned_by BIGINT UNSIGNED NOT NULL,
  joined_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  removed_at DATETIME NULL,
  CONSTRAINT uq_project_member UNIQUE (project_id, user_id),
  CONSTRAINT fk_members_project FOREIGN KEY (project_id) REFERENCES projects(id),
  CONSTRAINT fk_members_user FOREIGN KEY (user_id) REFERENCES users(id),
  CONSTRAINT fk_members_assigner FOREIGN KEY (assigned_by) REFERENCES users(id),
  INDEX idx_members_user_active (user_id, removed_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tasks (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  project_id BIGINT UNSIGNED NOT NULL,
  assigned_to BIGINT UNSIGNED NOT NULL,
  created_by BIGINT UNSIGNED NOT NULL,
  title VARCHAR(200) NOT NULL,
  description TEXT NOT NULL,
  priority ENUM('low','medium','high','urgent') NOT NULL DEFAULT 'medium',
  status ENUM('new','in_progress','blocked','pending_review','changes_requested','completed') NOT NULL DEFAULT 'new',
  due_date DATE NULL,
  submitted_at DATETIME NULL,
  completed_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_tasks_project FOREIGN KEY (project_id) REFERENCES projects(id),
  CONSTRAINT fk_tasks_assignee FOREIGN KEY (assigned_to) REFERENCES users(id),
  CONSTRAINT fk_tasks_creator FOREIGN KEY (created_by) REFERENCES users(id),
  INDEX idx_tasks_assignee_status (assigned_to, status),
  INDEX idx_tasks_project_status (project_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE task_reviews (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  task_id BIGINT UNSIGNED NOT NULL,
  reviewed_by BIGINT UNSIGNED NOT NULL,
  decision ENUM('approved','changes_requested') NOT NULL,
  comments TEXT NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_reviews_task FOREIGN KEY (task_id) REFERENCES tasks(id),
  CONSTRAINT fk_reviews_reviewer FOREIGN KEY (reviewed_by) REFERENCES users(id),
  INDEX idx_reviews_task_date (task_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE conversations (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  request_id BIGINT UNSIGNED NULL,
  project_id BIGINT UNSIGNED NULL,
  created_by BIGINT UNSIGNED NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_conversations_request FOREIGN KEY (request_id) REFERENCES project_requests(id),
  CONSTRAINT fk_conversations_project FOREIGN KEY (project_id) REFERENCES projects(id),
  CONSTRAINT fk_conversations_creator FOREIGN KEY (created_by) REFERENCES users(id),
  INDEX idx_conversations_request (request_id),
  INDEX idx_conversations_project (project_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE conversation_members (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  conversation_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  joined_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  left_at DATETIME NULL,
  CONSTRAINT uq_conversation_member UNIQUE (conversation_id, user_id),
  CONSTRAINT fk_conversation_members_conversation FOREIGN KEY (conversation_id) REFERENCES conversations(id),
  CONSTRAINT fk_conversation_members_user FOREIGN KEY (user_id) REFERENCES users(id),
  INDEX idx_conversation_members_user (user_id, left_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE messages (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  conversation_id BIGINT UNSIGNED NOT NULL,
  sender_id BIGINT UNSIGNED NOT NULL,
  message_body TEXT NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  edited_at DATETIME NULL,
  CONSTRAINT fk_messages_conversation FOREIGN KEY (conversation_id) REFERENCES conversations(id),
  CONSTRAINT fk_messages_sender FOREIGN KEY (sender_id) REFERENCES users(id),
  INDEX idx_messages_conversation_date (conversation_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE files (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  uploaded_by BIGINT UNSIGNED NOT NULL,
  project_id BIGINT UNSIGNED NULL,
  request_id BIGINT UNSIGNED NULL,
  task_id BIGINT UNSIGNED NULL,
  message_id BIGINT UNSIGNED NULL,
  delivery_id BIGINT UNSIGNED NULL,
  original_name VARCHAR(255) NOT NULL,
  storage_name VARCHAR(255) NOT NULL UNIQUE,
  storage_path VARCHAR(500) NOT NULL,
  mime_type VARCHAR(120) NOT NULL,
  file_size BIGINT UNSIGNED NOT NULL,
  checksum CHAR(64) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_files_uploader FOREIGN KEY (uploaded_by) REFERENCES users(id),
  CONSTRAINT fk_files_project FOREIGN KEY (project_id) REFERENCES projects(id),
  CONSTRAINT fk_files_request FOREIGN KEY (request_id) REFERENCES project_requests(id),
  CONSTRAINT fk_files_task FOREIGN KEY (task_id) REFERENCES tasks(id),
  CONSTRAINT fk_files_message FOREIGN KEY (message_id) REFERENCES messages(id),
  INDEX idx_files_context (project_id, request_id, task_id, message_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE financial_transactions (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  project_id BIGINT UNSIGNED NULL,
  created_by BIGINT UNSIGNED NOT NULL,
  transaction_type ENUM('payment','expense') NOT NULL,
  amount DECIMAL(19,4) NOT NULL,
  currency_id SMALLINT UNSIGNED NOT NULL,
  transaction_date DATE NOT NULL,
  payment_method VARCHAR(80) NULL,
  reference_number VARCHAR(120) NULL,
  description TEXT NOT NULL,
  status ENUM('draft','approved','voided') NOT NULL DEFAULT 'approved',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_finance_project FOREIGN KEY (project_id) REFERENCES projects(id),
  CONSTRAINT fk_finance_creator FOREIGN KEY (created_by) REFERENCES users(id),
  CONSTRAINT fk_finance_currency FOREIGN KEY (currency_id) REFERENCES currencies(id),
  INDEX idx_finance_date_type (transaction_date, transaction_type),
  INDEX idx_finance_project (project_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE notifications (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  title VARCHAR(200) NOT NULL,
  body TEXT NOT NULL,
  notification_type VARCHAR(80) NOT NULL,
  related_type VARCHAR(80) NULL,
  related_id BIGINT UNSIGNED NULL,
  read_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_notifications_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_notifications_user_read (user_id, read_at, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE deliveries (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  project_id BIGINT UNSIGNED NOT NULL,
  created_by BIGINT UNSIGNED NOT NULL,
  version_number INT UNSIGNED NOT NULL,
  title VARCHAR(200) NOT NULL,
  description TEXT NOT NULL,
  status ENUM('draft','submitted','changes_requested','approved') NOT NULL DEFAULT 'draft',
  submitted_at DATETIME NULL,
  approved_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT uq_delivery_version UNIQUE (project_id, version_number),
  CONSTRAINT fk_deliveries_project FOREIGN KEY (project_id) REFERENCES projects(id),
  CONSTRAINT fk_deliveries_creator FOREIGN KEY (created_by) REFERENCES users(id),
  INDEX idx_deliveries_project_status (project_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO currencies (code, name, symbol, decimal_places, is_active) VALUES
('USD', 'US Dollar', '$', 2, 1),
('YER', 'Yemeni Rial', '﷼', 2, 1)
ON DUPLICATE KEY UPDATE name=VALUES(name), symbol=VALUES(symbol), decimal_places=VALUES(decimal_places), is_active=VALUES(is_active);
