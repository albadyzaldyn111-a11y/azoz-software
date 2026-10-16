<?php
declare(strict_types=1);
require_once __DIR__ . '/../config/bootstrap.php';
$user = \Azoz\Auth::user();
?><!doctype html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><?= e(getenv('APP_NAME') ?: 'Azoz Software') ?></title>
    <link rel="stylesheet" href="/assets/css/app.css">
</head>
<body>
<header class="site-header"><strong>Azoz Software</strong><nav><a href="/">الرئيسية</a><?php if ($user): ?><a href="/logout.php">تسجيل الخروج</a><?php else: ?><a class="button button-primary" href="/login.php">تسجيل الدخول</a><?php endif; ?></nav></header>
<main class="hero container"><span class="eyebrow">SOFTWARE AGENCY PLATFORM</span><h1>إدارة احترافية لدورة تطوير مشاريعك</h1><p>من طلب المشروع وعرض السعر إلى المهام والتسليمات، في مساحة واحدة آمنة ومنظمة.</p><?php if ($user): ?><p class="notice">مرحبًا <?= e($user['full_name']) ?> — دورك الحالي: <?= e($user['role']) ?></p><?php else: ?><a class="button button-primary" href="/login.php">الدخول إلى المنصة</a><?php endif; ?></main>
<footer class="site-footer">Azoz Software · الإصدار الأول قيد البناء</footer>
</body>
</html>
