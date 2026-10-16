<?php
declare(strict_types=1);

require_once __DIR__ . '/../app/Helpers/helpers.php';
require_once __DIR__ . '/../app/Database.php';
require_once __DIR__ . '/../app/Auth.php';

env_file(dirname(__DIR__) . '/.env');

date_default_timezone_set(getenv('APP_TIMEZONE') ?: 'UTC');

if (session_status() !== PHP_SESSION_ACTIVE) {
    $isHttps = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off');
    session_name(getenv('SESSION_NAME') ?: 'azoz_session');
    session_set_cookie_params([
        'lifetime' => 0,
        'path' => '/',
        'secure' => $isHttps,
        'httponly' => true,
        'samesite' => 'Lax',
    ]);
    session_start();
}
