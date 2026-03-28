<?php
// Simple health check - no Laravel dependencies

header('Content-Type: application/json');

$health = [
    'timestamp' => date('c'),
    'status' => 'healthy',
    'application' => 'RealVest',
    'environment' => getenv('APP_ENV') ?: 'unknown',
    'php_version' => phpversion(),
    'memory_limit' => ini_get('memory_limit'),
];

// Check .env
if (file_exists('../../.env')) {
    $health['.env'] = 'found';
} else {
    $health['.env'] = 'missing';
}

// Check vendor
if (file_exists('../../vendor/autoload.php')) {
    $health['dependencies'] = 'installed';
} else {
    $health['dependencies'] = 'missing';
}

// Try database connection if Laravel is available
if (file_exists('../../vendor/autoload.php')) {
    try {
        require '../../vendor/autoload.php';
        $env = parse_ini_file('../../.env');
        $health['database'] = [
            'host' => $env['DB_HOST'],
            'database' => $env['DB_DATABASE'],
            'status' => 'configured'
        ];
    } catch (Exception $e) {
        $health['bootstrap_error'] = $e->getMessage();
    }
}

http_response_code(200);
echo json_encode($health, JSON_PRETTY_PRINT);
