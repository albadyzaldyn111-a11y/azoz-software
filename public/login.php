<?php
declare(strict_types=1);
require_once __DIR__ . '/../config/bootstrap.php';
\Azoz\Auth::requireGuest();
$error = null;
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (!verify_csrf($_POST['_csrf'] ?? null)) {
        $error = 'انتهت صلاحية النموذج. أعد المحاولة.';
    } elseif (!filter_var($_POST['email'] ?? '', FILTER_VALIDATE_EMAIL) || strlen((string)($_POST['password'] ?? '')) < 1) {
        $error = 'أدخل بريدًا إلكترونيًا وكلمة مرور صحيحة.';
    } elseif (!\Azoz\Auth::attempt((string) $_POST['email'], (string) $_POST['password'])) {
        $error = 'بيانات الدخول غير صحيحة أو الحساب غير فعال.';
    } else {
        redirect('/');
    }
}
?><!doctype html>
<html lang="ar" dir="rtl"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>تسجيل الدخول · Azoz Software</title><link rel="stylesheet" href="/assets/css/app.css"></head>
<body><main class="auth-shell"><section class="auth-card"><a class="brand" href="/">Azoz Software</a><h1>تسجيل الدخول</h1><p class="muted">ادخل إلى مساحة العمل الخاصة بك.</p><?php if ($error): ?><div class="error" role="alert"><?= e($error) ?></div><?php endif; ?><form method="post" novalidate><input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>"><label for="email">البريد الإلكتروني</label><input id="email" name="email" type="email" autocomplete="email" required value="<?= e($_POST['email'] ?? '') ?>"><label for="password">كلمة المرور</label><input id="password" name="password" type="password" autocomplete="current-password" required><button class="button button-primary button-block" type="submit">دخول</button></form><a class="back-link" href="/">العودة للرئيسية</a></section></main></body></html>
