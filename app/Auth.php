<?php
declare(strict_types=1);

namespace Azoz;

use PDO;

final class Auth
{
    public static function user(): ?array
    {
        $id = $_SESSION['user_id'] ?? null;
        if (!is_int($id) && !ctype_digit((string) $id)) {
            return null;
        }
        $statement = Database::connection()->prepare('SELECT id, full_name, email, role, status FROM users WHERE id = :id LIMIT 1');
        $statement->execute(['id' => (int) $id]);
        $user = $statement->fetch();
        if (!$user || $user['status'] !== 'active') {
            self::logout();
            return null;
        }
        return $user;
    }

    public static function attempt(string $email, string $password): bool
    {
        $statement = Database::connection()->prepare('SELECT * FROM users WHERE email = :email LIMIT 1');
        $statement->execute(['email' => strtolower(trim($email))]);
        $user = $statement->fetch();
        if (!$user || $user['status'] !== 'active' || !password_verify($password, $user['password_hash'])) {
            return false;
        }
        session_regenerate_id(true);
        $_SESSION['user_id'] = (int) $user['id'];
        Database::connection()->prepare('UPDATE users SET last_login_at = NOW() WHERE id = :id')->execute(['id' => $user['id']]);
        return true;
    }

    public static function requireGuest(): void
    {
        if (self::user() !== null) {
            redirect('/');
        }
    }

    public static function requireAuth(?string $role = null): array
    {
        $user = self::user();
        if ($user === null) {
            redirect('/login.php');
        }
        if ($role !== null && $user['role'] !== $role) {
            http_response_code(403);
            exit('Forbidden');
        }
        return $user;
    }

    public static function logout(): void
    {
        $_SESSION = [];
        if (ini_get('session.use_cookies')) {
            $params = session_get_cookie_params();
            setcookie(session_name(), '', time() - 42000, $params['path'], $params['domain'], (bool) $params['secure'], (bool) $params['httponly']);
        }
        if (session_status() === PHP_SESSION_ACTIVE) {
            session_destroy();
        }
    }
}
