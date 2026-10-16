MASTER BUILD PROMPT: AZOZ SOFTWARE

1. Your Role and Mission

Act as a senior software architect, full-stack PHP developer, database engineer, security engineer, UI/UX designer, and DevOps engineer.

Your mission is to implement Azoz Software, a production-minded web platform for managing a small software development agency.

This is an implementation task, not a proposal, mockup, or planning-only task. Inspect the available tools and environment, create the actual project files, implement the database and application logic, run all feasible checks, create a GitHub repository, and publish the source code to it.

Work carefully and incrementally. Correctness, security, maintainability, and compatibility take priority over speed and unnecessary features.

The complete project requirements are provided in the accompanying Azoz Software system-building document. If that document is available as an attachment or file, read it completely before implementation. If it is not accessible, use the requirements in this prompt as the initial specification and document any missing details.

Do not claim that a feature works unless its implementation and available verification support that claim.

2. Project Identity

Project name: Azoz Software

Repository name: "azoz-software"

Application type: Responsive web application for a software development agency.

Primary language: Arabic.

Future language support: English.

Primary audience:

- Agency administrator.
- Clients and small businesses.
- Developers invited by the administrator.

Required core modules:

- User authentication and authorization.
- Client registration and email verification.
- Administrator access.
- Developer invitations.
- Project requests.
- Quotations and quotation versions.
- Project management.
- Task assignment and review.
- Private messaging.
- Private file uploads and downloads.
- Project deliveries.
- Financial transaction records.
- Multiple currencies.
- Notifications.
- Administrative reports.
- Audit logs.
- Application settings.

Payment processing, a public freelancer marketplace, a native mobile application, and AI code generation are outside the initial scope.

3. Mandatory First Steps

Before writing the application:

1. Inspect the available development environment and connected integrations.
2. Check whether GitHub access is available and authorized.
3. Read the complete project specification if available.
4. Inspect the target hosting provider's current technical limitations and acceptable-use rules.
5. Confirm the available PHP version, MySQL/MariaDB support, HTTPS availability, storage restrictions, upload limits, outbound SMTP restrictions, and deployment options.
6. Create a concise implementation plan and a requirements-to-files mapping.
7. Create the GitHub repository "azoz-software" under the authorized GitHub account.
8. Initialize Git and make the first commit containing the project structure, README, and implementation plan.
9. Continue implementation in small, coherent commits.

If GitHub authentication or permission is unavailable, prepare the complete local Git repository and explain exactly what authorization is needed. Do not claim that a remote repository was created or updated unless GitHub confirms the action.

Do not expose access tokens, credentials, private keys, or environment variables in logs, screenshots, source files, or the repository.

4. Technology Stack

Use the following stack unless the verified hosting constraints require a documented adjustment:

- PHP 8.x, using a version actually supported by the target host.
- MySQL or MariaDB.
- PDO with prepared statements.
- HTML5.
- CSS3.
- Vanilla JavaScript.
- Git and GitHub.
- SMTP through an external email provider when available and permitted.

Prefer a lightweight, maintainable architecture compatible with conventional PHP shared hosting.

Do not require Node.js, Docker, Redis, background workers, WebSockets, or a permanently running server in production unless the hosting environment explicitly supports them and the need is justified.

Avoid unnecessary dependencies, paid APIs, paid templates, and services requiring a subscription.

Do not introduce Laravel or another large framework without first verifying that its deployment requirements are compatible with the target hosting plan.

The application must remain deployable to a conventional PHP/MySQL host. Development tools may be used locally when available, but must not become undocumented production dependencies.

5. Hosting Compatibility and Restrictions

The initial target is InfinityFree, subject to verification of its current plan and policies.

Official starting point:
https://www.infinityfree.com/

Investigate current official documentation and terms before making hosting-specific claims.

Do not assume that every capability is supported simply because PHP and MySQL are available.

In particular:

- Verify the supported PHP and database versions.
- Verify HTTPS behavior and session requirements.
- Verify maximum upload sizes and storage restrictions.
- Verify outbound SMTP connectivity and the chosen email provider's requirements.
- Do not rely on PHP "mail()" or assume SMTP works without verification.
- Do not rely on scheduled cron jobs unless the plan explicitly supports them.
- Do not require shell access, Composer on the production host, or SSH deployment unless actually available.
- Do not assume that private directories outside the public web root are possible without checking the deployment structure.
- Do not store sensitive uploaded files in a publicly accessible directory without a verified access-control mechanism.
- Do not create a workaround that violates hosting terms or bypasses resource limits.
- Do not use the free host for a feature it cannot safely support.

If a critical requirement cannot be implemented securely on the target host, implement a safe alternative where possible and document the remaining limitation. If no safe alternative exists, identify the blocking issue instead of pretending it is solved.

The application should degrade gracefully when email delivery or another external service is unavailable.

6. Professional Corporate Design

Design a polished, premium software-agency platform.

The visual identity should feel like a real software company: restrained, elegant, modern, trustworthy, and suitable for business clients.

Design direction:

- Dark navy or charcoal as the main visual foundation.
- White or light neutral surfaces for readable content.
- Restrained red accents for important actions and brand recognition.
- Subtle borders and carefully controlled shadows.
- Clear typography and excellent Arabic readability.
- Generous but efficient spacing.
- Professional tables, forms, dialogs, and dashboards.
- Consistent icons and interaction states.
- Responsive layouts for mobile, tablet, and desktop.
- A clean layout without excessive animation.
- No cyberpunk, neon-green hacker aesthetics, excessive gradients, or cluttered dashboard cards.

Build a coherent design system with reusable CSS variables for colors, spacing, typography, borders, radii, and component states.

Use a consistent component style for:

- Buttons.
- Form controls.
- Navigation.
- Sidebar.
- Tables.
- Status labels.
- Notifications.
- Dialogs.
- Empty states.
- Error messages.
- Confirmation messages.
- Loading states.

Use Arabic as the default language with "lang="ar"" and "dir="rtl"" on Arabic pages.

Ensure that forms, tables, icons, sidebars, pagination, and modal dialogs work correctly in RTL layouts.

Avoid mixing Arabic and English awkwardly. Use English only where it is technically appropriate, such as identifiers or technical labels.

The public website should present the agency professionally, while the administrator, client, and developer portals should have distinct navigation appropriate to each role.

Use a consistent brand name: Azoz Software.

Do not invent customer testimonials, customer logos, awards, project statistics, or company credentials. Use clearly identified sample content only where necessary.

7. Architecture and Code Organization

Keep the project modular and understandable.

Use a structure similar to:

"public/"

- "index.php"
- "login.php"
- "register.php"
- "verify-email.php"
- "forgot-password.php"
- "reset-password.php"
- "logout.php"
- "admin/"
- "client/"
- "developer/"
- "assets/css/"
- "assets/js/"
- "assets/images/"

"app/"

- "Controllers/"
- "Models/"
- "Repositories/"
- "Services/"
- "Views/"
- "Middleware/"
- "Helpers/"
- "Validators/"

"config/"

- Application configuration.
- Database configuration template.

"database/"

- "schema.sql"
- Versioned migration files where needed.

"storage/"

- Private uploaded files.
- Temporary files.
- Logs.

Also include:

- ".gitignore"
- ".env.example" if environment-variable configuration is supported.
- "README.md"
- "INSTALL.md"
- "DEPLOYMENT.md"
- "SECURITY.md"
- "CHANGELOG.md"
- "LICENSE" only after selecting an appropriate license deliberately.

Adapt this structure to the actual hosting document root. If the host requires a particular public directory, configure deployment so private application files and credentials are not exposed.

Separate business logic, data access, validation, and page rendering. Avoid giant PHP files that contain database logic, authentication, and all page markup together.

Do not add empty placeholder modules and report them as completed functionality.

8. Authentication and Authorization

Implement the following roles:

1. "admin"
2. "client"
3. "developer"

Requirements:

- Public registration creates client accounts only.
- Never accept an arbitrary role from a registration form or query parameter.
- Never allow a user to promote themselves to administrator.
- Create the first administrator through a secure, one-time setup procedure.
- Disable or remove the setup procedure after successful initialization.
- Developers join through valid, expiring invitations.
- Use PHP "password_hash()" and "password_verify()".
- Use secure, random tokens for email verification, password resets, and invitations.
- Store token hashes when appropriate.
- Make tokens expire and invalidate them after use.
- Use safe session configuration and regenerate session IDs after authentication.
- Enforce authorization on the server for every protected operation.
- Verify record ownership and project membership on every relevant read, update, download, and delete request.
- Rate-limit authentication and recovery attempts.
- Avoid account enumeration in password recovery responses.
- Log important administrative security events without logging secrets.
- Ensure that logout invalidates the session correctly.

Do not rely on hidden navigation items as an authorization mechanism.

9. Core Business Workflows

A. Client Registration

Implement registration, email verification, login, logout, profile management, and password recovery.

An account requiring email verification must not gain normal access before verification.

B. Developer Invitations

Administrators can invite developers by email.

Invitations must be secure, expiring, revocable, and single-use.

C. Project Requests

Clients can submit a project title, description, service category, optional budget, currency, expected deadline, and relevant attachments.

Administrators can review requests, ask for additional information, qualify requests, or reject them with a reason.

D. Quotations

Administrators can create quotations containing:

- Scope of work.
- Price.
- Currency.
- Estimated duration.
- Payment terms.
- Delivery terms.
- Expiration date.

Maintain immutable historical quotation versions.

Clients can accept or reject a valid quotation. Record the decision, timestamp, and exact quotation version.

Only create a project after a valid quotation has been accepted and the database operation succeeds.

E. Projects and Members

Administrators can manage project status, dates, descriptions, and developer membership.

Clients can see only their own projects.

Developers can see only projects to which they have been assigned.

F. Tasks and Reviews

Administrators can create and assign tasks.

Developers can update assigned tasks, upload work, and submit tasks for review.

Administrators can approve tasks or request changes with comments.

A developer must not be able to approve their own submitted work as an administrator.

G. Conversations and Messages

Implement conversations linked to a project or project request.

Only authorized participants may read or send messages.

H. Private Files

Implement secure uploads and downloads for authorized users.

Files must have size limits, validated types, randomized storage names, and authorization checks on download.

Never trust the browser-provided MIME type or filename.

Do not permit uploaded scripts or executable files to run on the server.

If the target host cannot safely protect private file storage, stop and document the limitation before exposing sensitive uploads.

I. Deliveries

Administrators can create versioned deliveries containing descriptions and associated files.

Clients can view their deliveries and submit feedback according to the agreed workflow.

J. Financial Records

Administrators can record received payments and actual expenses.

The system records transactions; it does not process payments.

Support multiple currencies. Never sum different currencies into a single financial total without a documented exchange-rate conversion.

Keep quotation values, expected payments, received payments, and actual expenses conceptually separate.

Prevent casual permanent deletion of approved financial records. Record corrections through a controlled process.

K. Notifications and Reports

Implement in-app notifications and role-appropriate dashboards.

Provide administrative reports for requests, quotations, projects, overdue tasks, payments, expenses, and audit events.

Filter reports by date, project, status, and currency where applicable.

L. Audit Logs

Record sensitive actions such as:

- User suspension and reactivation.
- Developer invitations and revocations.
- Quotation creation and decisions.
- Project status changes.
- Task approvals and revision requests.
- Financial record creation and correction.
- Administrative settings changes.

Never store passwords, raw reset tokens, SMTP passwords, or API keys in audit logs.

10. Database Implementation

Implement a normalized relational database with appropriate primary keys, foreign keys, unique constraints, indexes, and timestamps.

At minimum, provide tables for:

- "users"
- "email_verifications"
- "password_resets"
- "developer_invitations"
- "login_attempts"
- "audit_logs"
- "currencies"
- "project_requests"
- "quotations"
- "quotation_decisions"
- "projects"
- "project_members"
- "tasks"
- "task_reviews"
- "conversations"
- "conversation_members"
- "messages"
- "files"
- "financial_transactions"
- "notifications"
- "deliveries"

Use InnoDB and "utf8mb4" where supported.

Use suitable decimal types for financial amounts.

Ensure that:

- Email addresses are unique.
- Quotation version numbers are unique within their requests.
- Project membership cannot be duplicated accidentally.
- Relationships have deliberate deletion behavior.
- Financial and historical records are not unintentionally deleted by cascading operations.
- Queries are indexed for common filters and joins.
- Multi-step operations use transactions where appropriate.
- Concurrent quotation decisions cannot create duplicate projects.
- Database errors are handled safely.

Provide a complete, importable "database/schema.sql" and any required migration files.

The installation guide must explain how to create the database and import the schema using the hosting control panel or phpMyAdmin if command-line access is unavailable.

11. Financial and Currency Rules

Use a currency table with a code, name, symbol, decimal precision, and active status.

Store the currency with each quotation and financial transaction.

Do not silently change the currency of existing records.

Do not calculate a cross-currency grand total without an explicit conversion rate, conversion date, and documented source.

Use decimal database types rather than floating-point storage for monetary values.

Clearly distinguish:

- Quoted amount.
- Expected payment.
- Received payment.
- Actual expense.
- Outstanding amount where its calculation is meaningful.

Do not advertise the financial module as a complete accounting system.

12. Security Requirements

Implement protections appropriate for a PHP web application, including:

- Prepared SQL statements.
- Server-side input validation.
- Context-aware HTML output escaping.
- CSRF protection for state-changing actions.
- Secure session settings.
- Password hashing.
- Authorization and ownership checks.
- Rate limiting for sensitive endpoints.
- Safe error handling.
- Restricted file uploads.
- Private file downloads.
- Safe handling of redirects.
- Protection against mass assignment.
- Database transactions for critical workflows.
- HTTPS in production.
- No hardcoded credentials.
- No exposed debug output in production.
- No public access to private logs or configuration files.

Do not invent or claim that a security audit has passed without actually conducting and documenting the checks.

Never include real secrets in the GitHub repository.

13. Email and External Services

Email is required for verification, invitations, and password recovery.

Investigate a suitable external SMTP provider and confirm whether it offers a free tier that is currently available and compatible with the intended use.

Do not assume that free SMTP access is guaranteed, and do not use PHP "mail()" as a guaranteed solution on InfinityFree.

If credentials are required:

- Provide a ".env.example" with placeholder values.
- Keep actual credentials out of Git.
- Document the provider configuration.
- Provide clear failure handling if the provider is unavailable.

Do not expose whether a particular email address belongs to a registered user through public error messages.

14. Implementation Quality

Implement real functionality, not decorative mockups.

For every form:

- Validate inputs on the server.
- Show useful validation errors.
- Persist data correctly.
- Handle failures safely.
- Prevent unauthorized changes.
- Provide a clear success or failure result.

For every list:

- Load real data from the database.
- Apply appropriate authorization filters.
- Support useful filtering and pagination where needed.
- Handle empty states and database failures.

For every action:

- Use the correct HTTP method.
- Enforce authorization.
- Validate the target record.
- Record audit information when appropriate.
- Confirm that the operation actually succeeded.

Do not insert fake counts into dashboards.

Do not create buttons that do nothing.

Do not mark a feature complete merely because a corresponding page exists.

Do not create fake login flows that bypass the database.

If a service is not configured, show its true configuration status and explain what is needed.

15. Verification and Quality Checks

The objective is to avoid unnecessary overhead, but essential verification cannot be skipped.

Run all checks that are feasible in the available environment, including:

- PHP syntax checks.
- SQL schema inspection.
- Database connection verification.
- Import of the schema into a test database when available.
- Authentication and role checks.
- Server-side input validation checks.
- Authorization and record-ownership checks.
- File access-control checks.
- Basic responsive and RTL inspection.
- Verification that the application does not depend on unavailable production services.

Do not claim that tests passed if they were not run.

If the environment does not support a particular check, record it as unverified and explain why.

Do not use fake test results, fabricated screenshots, or simulated successful deployments.

16. GitHub Repository Management

Create the remote repository "azoz-software" using the authorized GitHub integration.

Use a sensible initial branch name, such as "main".

Commit in logical stages, for example:

1. Initial project structure and documentation.
2. Database schema and configuration.
3. Authentication and authorization.
4. Project requests and quotations.
5. Projects, tasks, and reviews.
6. Messages, files, and deliveries.
7. Financial records and reports.
8. Security hardening and deployment documentation.

Adjust the commit sequence to match the actual implementation.

Before every push:

- Review staged files.
- Check that no credentials, private keys, ".env" files, database dumps with real data, session files, or uploaded customer files are included.
- Check ".gitignore".
- Review the repository contents.

Create a useful "README.md" that explains the project, its features, requirements, setup, deployment, and known limitations.

Create "INSTALL.md" and "DEPLOYMENT.md" with precise setup instructions.

If the repository is private, keep it private unless the account owner explicitly authorizes making it public.

Never change repository visibility or overwrite an existing unrelated repository without authorization.

Report the actual repository URL after GitHub confirms creation.

17. Deployment Requirements

Prepare the application for deployment to InfinityFree or another verified PHP/MySQL host.

Document:

- Supported PHP version.
- Required PHP extensions.
- Database creation and schema import.
- Configuration of database credentials.
- Configuration of SMTP.
- HTTPS setup.
- Creation of the first administrator.
- File-storage requirements.
- Backup and restoration procedures.
- Deployment limitations.
- Steps for updating the application safely.

Do not automatically deploy to a live site unless the necessary access is authorized and the target is confirmed.

Never place production credentials in the repository.

18. Execution Rules

Work autonomously within the permissions and tools already available.

Do not stop after producing another plan or writing documentation.

Create the actual files and implement the core application.

Do not ask me to manually perform steps that your available tools can safely perform themselves.

If an action requires my authorization, account login, or a permission that is unavailable, identify that exact blocker and continue with other independent work.

If a technical decision is not specified, choose a conservative, maintainable default and document it.

Do not silently remove a required feature to make deployment easier.

Do not violate hosting terms or attempt to bypass platform restrictions.

Do not claim completion prematurely.

19. Final Deliverables

At the end, provide a factual implementation report containing:

1. GitHub repository URL.
2. Repository visibility and branch name.
3. Implemented modules.
4. Database schema and installation files.
5. Application directory structure.
6. Security measures implemented.
7. Checks actually executed and their results.
8. Hosting compatibility findings.
9. Email and SMTP configuration status.
10. Deployment status.
11. Features that remain incomplete.
12. Known security or operational limitations.
13. Exact next steps required from the owner.

Clearly separate:

- Implemented and verified.
- Implemented but not verified.
- Not implemented.
- Blocked by unavailable permissions or hosting limitations.

The final result must be a real, maintainable, documented software project in GitHub, not merely a visual prototype.

Begin by inspecting the environment and available permissions, then create the repository and proceed with implementation.