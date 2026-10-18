<?php
declare(strict_types=1);

ini_set('session.use_strict_mode', '1');
ini_set('session.use_only_cookies', '1');
session_set_cookie_params([
    'path' => '/',
    'httponly' => true,
    'secure' => isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off',
    'samesite' => 'Lax',
]);
session_start();

$dbHost = getenv('DB_HOST') ?: '127.0.0.1';
$dbPort = getenv('DB_PORT') ?: '3306';
$dbName = getenv('DB_NAME') ?: 'skillpass';
$dbUser = getenv('DB_USER') ?: 'root';
$dbPassword = getenv('DB_PASSWORD') ?: '';
$whatsappNumber = '237672828084';

try {
    $pdo = new PDO(
        "mysql:host={$dbHost};port={$dbPort};dbname={$dbName};charset=utf8mb4",
        $dbUser,
        $dbPassword,
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ]
    );
} catch (PDOException $exception) {
    error_log('SkillPass database connection failed: ' . $exception->getMessage());
    http_response_code(500);
    exit('Unable to connect to the SkillPass database. Import database.sql and check the database settings in config.php.');
}

function e(string|int|float|null $value): string
{
    return htmlspecialchars((string) $value, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}

function redirect(string $url): void
{
    header('Location: ' . $url);
    exit;
}

function csrf_token(): string
{
    if (!isset($_SESSION['csrf_token'])) {
        $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
    }

    return $_SESSION['csrf_token'];
}

function verify_csrf(): void
{
    $submitted = $_POST['csrf_token'] ?? '';
    if (!is_string($submitted) || !hash_equals(csrf_token(), $submitted)) {
        http_response_code(419);
        exit('Your form session expired. Go back, refresh the page, and try again.');
    }
}

function flash(string $message, string $type = 'success'): void
{
    $_SESSION['flash'] = ['message' => $message, 'type' => $type];
}

function current_user(): ?array
{
    return isset($_SESSION['user']) && is_array($_SESSION['user']) ? $_SESSION['user'] : null;
}

function require_role(string $role): array
{
    $user = current_user();
    if (!$user || $user['role'] !== $role) {
        flash('Please sign in to continue.', 'error');
        redirect('index.php?page=login');
    }

    return $user;
}

function parse_skill_names(string $input): array
{
    $names = array_map('trim', explode(',', $input));
    $names = array_filter($names, static fn (string $name): bool => $name !== '');
    $names = array_map(static fn (string $name): string => mb_substr($name, 0, 60), $names);

    $unique = [];
    foreach ($names as $name) {
        $slug = strtolower(trim((string) preg_replace('/[^a-z0-9]+/i', '-', $name), '-'));
        if ($slug !== '') {
            $unique[$slug] = $name;
        }
    }

    return array_values($unique);
}

function valid_evidence_url(string $url): bool
{
    if (!filter_var($url, FILTER_VALIDATE_URL)) {
        return false;
    }

    $scheme = strtolower((string) parse_url($url, PHP_URL_SCHEME));
    return in_array($scheme, ['http', 'https'], true);
}

function save_skill_list(PDO $pdo, int $userId, string $input): void
{
    $pdo->prepare('DELETE FROM user_skills WHERE user_id = ?')->execute([$userId]);
    $insertSkill = $pdo->prepare(
        'INSERT INTO skills (name, slug) VALUES (?, ?)
         ON DUPLICATE KEY UPDATE id = LAST_INSERT_ID(id)'
    );
    $getSkill = $pdo->prepare('SELECT id FROM skills WHERE slug = ?');
    $linkSkill = $pdo->prepare('INSERT INTO user_skills (user_id, skill_id) VALUES (?, ?)');

    foreach (parse_skill_names($input) as $name) {
        $slug = strtolower(trim((string) preg_replace('/[^a-z0-9]+/i', '-', $name), '-'));
        if ($slug === '') {
            continue;
        }

        $insertSkill->execute([$name, $slug]);
        $getSkill->execute([$slug]);
        $skillId = $getSkill->fetchColumn();
        if ($skillId) {
            $linkSkill->execute([$userId, (int) $skillId]);
        }
    }
}
